# encoding: utf-8

require 'net/http'
require 'json'
require 'airbrake'
require 'date'

Airbrake.configure do |config|
  config.api_key = 'f7c9ab3f84b97f7fc03faea5583cb1f0'
end


class Orders < Thor

  DOMAIN = {
    pedrocinefoto: '127.0.0.1:9999',
    production:    '127.0.0.1:9999', # DEPRECATED will be removed soon in favor of pcf
    indefinido:    'kuva.indefini.do',
    development:   'kuva.dev'
  }

  USERNAME = 'pedrocinefoto'
  PASSWORD = 'kuvaapi'

  DOWNLOAD_PATH = {
    pedrocinefoto: '/digital/Kuva',
    production:    '/digital/Kuva', # DEPRECATED will be removed soon in favor of pcf
    indefinido:    '/digital/Kuva',
    development:   'tmp/downloads'
  }



  desc "search", "Busca ordens de serviço"

  method_option :environment, :aliases => "-e", :desc => "Sets the app environment"

  def search
    order  = nil
    orders = JSON.parse(closed_orders_ids)

    puts "#{orders.count} ordens de serviço encontradas! \n\n" if orders.count > 0
    orders.each do |order|
      capture_order order
    end
    puts "\n\n\n" if orders.count > 0

  rescue => e
    notify e, parameters: { order_id: (order && order['id']) }
    raise e
  end




private

  # # Overriding puts do add some debug information
  # def puts str
  #   @id ||= "#{rand(1000)} #{`date`}"
  #   super "#{@id} => #{str}"
  # end

  def closed_orders_ids
    ids = []

    uri = URI("http://#{domain}/api/orders/closed.json")
    req = Net::HTTP::Get.new(uri.request_uri)

    req.basic_auth USERNAME, PASSWORD

    res = Net::HTTP.start(uri.hostname, uri.port) do |http|
      response = http.request(req)
      ids = response.body
    end

    ids
  end


  def capture_order order
    id   = order['id']
    name = order['name']

    puts "Capturando ordem de serviço #{id}\n"

    tmp_path         = "/tmp/#{id}.zip"
    destination_path = destination_folder

    # download
    puts   "  Fazendo download..."
    uri = URI("http://#{domain}/api/orders/#{id}/download")
    req = Net::HTTP::Get.new(uri.request_uri)
    req.basic_auth USERNAME, PASSWORD
    res = Net::HTTP.start(uri.hostname, uri.port) { |http|
      http.read_timeout = 99999 # allows compression to complete
      http.request(req)
    }
    if res.is_a? Net::HTTPGone
      puts  "Ordem de serviço #{id} já foi capturada e será ignorada...\n\n"
      return
    elsif res.is_a? Net::HTTPInternalServerError
      puts  "Ocorreu um erro no servidor...\n\n"
      return
    else
      File.open(tmp_path, "w") do |file|
        file.write res.body
      end
    end
    print  "  Download concluído.\n"

    system "mkdir -p #{destination_path}"

    # unzip and use name instead of id
    if system "unzip #{tmp_path} -d #{destination_path}"

      # rename to a readable id
      if name != id
        system "mv #{destination_path}/#{id} #{destination_path}/#{name}"
        system "chmod -R g+w #{destination_path}/#{name}"
        puts "  Alterando nome de #{id} para #{name}"
      end

      # print
      puts "  Imprimindo..."

      pdf_name = "#{name}.pdf"
      pdf_path = "#{destination_path}/#{name}/#{pdf_name}"

      unless environment == :development
        # download pdf
        system "curl -o #{pdf_path} --user #{USERNAME}:#{PASSWORD} http://#{domain}/api/orders/#{id}.pdf"
        # print pdf
        system "lp -d os #{pdf_path}"
      else
        puts "    Simulando impressão."
      end

      puts "  Impressão concluída.\n"
    else
      notify error_class:   "DownloadError",
             error_message: "Error downloading order",
             parameters:    { order_id: id }
    end

    # clean
    system "rm #{tmp_path}"

    puts "Pronto!\n\n"
  end


  def destination_folder
    date = Date.today
    "#{download_path}/#{date.strftime('%Y%m')}/#{date.strftime('%d')}"
  end

  def notify *args
    Airbrake.notify *args unless environment == :development
  end

  def download_path
    DOWNLOAD_PATH[environment]
  end

  def domain
    DOMAIN[environment]
  end

  def environment
    (options[:environment] || :development).to_sym
  end

end