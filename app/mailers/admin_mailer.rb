class AdminMailer < ActionMailer::Base
  helper :orders
  
  default :from => "notification@kuva.com"
  default :to => "staff@kuva.com"
  
  def order_opened order
    @order = order
    @user = @order.user
    @name  = @user.try :name
    
    mail :subject => "Nova ordem aberta por #{@order.user.name}! [#{@order.id}]"
  end
  
  def order_closed order
    @order = order
    @user = @order.user
    @name  = @user.try :name
    
    mail :subject => "Ordem enviada por #{@order.user.name}! [#{@order.id}]"
  end
end
