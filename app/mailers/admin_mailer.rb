require 'notifiable'

class AdminMailer < ActionMailer::Base

  include Notifiable

  helper :orders

  default from: "Kuva - Pedro Cine Foto <pedrocinefoto@gmail.com>"
  default to:   ["Lucca Mordente <luccamordente@gmail.com>", "Heitor Salazar <heitorsalazar@gmail.com>", "Ricardo Mordente <ricardomordente@gmail.com>"]

  def order_opened order
    @order = order
    @user = @order.user
    @name  = @user.try :name

    mail subject: "Nova ordem aberta por #{@order.user.name}! [#{@order.id}]"
  end

  def order_closed order
    @order = order
    @user = @order.user
    @name  = @user.try :name

    mail subject: "Ordem enviada por #{@order.user.name}! [#{@order.id}]"
  end

  def order_closed_ios order
    notify ['luccamordente','pickachu','ricardo1216'], "OS ##{order.identifier human: true} enviada por #{order.user.name} no valor de #{view_context.number_to_currency order.price}"
  end

end
