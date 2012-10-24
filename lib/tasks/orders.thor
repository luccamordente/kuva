# encoding: utf-8`
require 'net/http'
require 'json'
require 'airbrake'
require 'date'

Airbrake.configure do |config|
  config.api_key = 'f7c9ab3f84b97f7fc03faea5583cb1f0'
end


class Orders < Thor

  DOMAIN = {
    production:  '127.0.0.1:9999',
    development: 'kuva.dev'
  }

  USERNAME = 'pedrocinefoto'
  PASSWORD = 'kuvaapi'

  DOWNLOAD_PATH = {
    production:  '/digital/Kuva',
    development: 'tmp/downloads'
  }



  desc "search", "Busca ordens de serviço"

  method_option :environment, :aliases => "-e", :desc => "Sets the app environment"

  def search
    id  = nil
    ids = JSON.parse(closed_orders_ids)

    puts "#{ids.count} ordens de serviço encontradas! \n\n" if ids.count > 0
    ids.each { |id| capture_order id }
    puts "\n\n\n" if ids.count > 0

  rescue => e
    notify e, parameters: { order_id: id }
    raise e
  end




private


  def closed_orders_ids
    ids = []

    uri = URI("http://#{domain}/api/orders/closed")
    req = Net::HTTP::Get.new(uri.request_uri)

    req.basic_auth USERNAME, PASSWORD

    res = Net::HTTP.start(uri.hostname, uri.port) do |http|
      response = http.request(req)
      ids = response.body
    end

    ids
  end


  def capture_order id
    puts "Capturando ordem de serviço #{id}\n"

    tmp_path = "tmp/downloads/#{id}.zip"

    puts "  Fazendo download..."
    system "curl -o #{tmp_path} --user #{USERNAME}:#{PASSWORD} http://kuva.dev/api/orders/#{id}/download "
    print "  Download concluído.\n"

    date = Date.today
    destination_folder = "#{download_path}/#{date.strftime('%Y%m')}/#{date.strftime('%d')}"
    system "mkdir -p #{destination_folder}"

    if system "unzip #{tmp_path} -d #{destination_folder}"
      puts "  Imprimindo..."
      # system "lp -d os #{destination_folder}/#{id}.pdf"
      puts "  Impressão concluída.\n"
    else
      notify error_class:   "DownloadError",
             error_message: "Error downloading order",
             parameters:    { order_id: id }
    end

    system "rm #{tmp_path}"

    puts "Pronto!\n\n"
  end



  def notify *args
    Airbrake.notify *args if environment == :production
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