require 'notifo'

module Notifiable

  def notify users, message, title=nil, uri=nil
    @notifo ||= Notifo.new NOTIFO_USERNAME, NOTIFO_API_KEY

    users = users.is_a?(Array) ? users : [users]

    out = []
    users.each do |user|
      out << @notifo.post(user, message, title, uri)
    end

    out
  end

end