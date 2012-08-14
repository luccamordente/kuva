# encoding: UTF-8

class UserMailer < ActionMailer::Base
  layout "user_mailer"
  helper :application
  
  default :from     => "Ricardo Mordente (Pedro Cine Foto) <ricardo@pedrocinefoto.com.br>"
  default :reply_to => "Ricardo Mordente (Pedro Cine Foto) <ricardo@pedrocinefoto.com.br>"
  
  def order_closed order
    @order = order
    @user  = @order.user
    @name  = @user.first_name
    
    mail :subject => "Recebemos suas fotos! Abra para instruções...",
         :to      => "#{@user.name} <#{@user.email}>"
  end
end
