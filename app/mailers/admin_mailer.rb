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

    notify ['luccamordente','ricardo1216'], 'Ordem enviada por #{@order.user.name}', nil, admin_order_url(@order) if Rails.env.production?

    mail subject: "Ordem enviada por #{@order.user.name}! [#{@order.id}]"
  end
end
