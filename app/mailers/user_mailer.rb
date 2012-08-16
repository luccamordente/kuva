# encoding: UTF-8

class UserMailer < ActionMailer::Base
  layout "user_mailer"
  helper :application
  
  default :from     => "Ricardo Mordente (Pedro Cine Foto) <ricardo@pedrocinefoto.com.br>"
  default :reply_to => "Ricardo Mordente (Pedro Cine Foto) <ricardo@pedrocinefoto.com.br>"
  
  def order_closed order
    @order = order
    @user  = @order.user
    
    mail :subject => "Recebemos suas fotos! Abra para instruções...",
         :to      => "#{@user.name} <#{@user.email}>"
  end
  
  
  def welcome_with_password_instructions user
    @user = user
    
    mail :subject => "Seu cadastro já está pronto! Abra e veja como acessar...",
         :to      => "#{@user.name} <#{@user.email}>"
  end
  
end
