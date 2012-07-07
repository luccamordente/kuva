class OrderMailer < ActionMailer::Base
  default :from => "notification@kuva.com"
  default :to => "staff@kuva.com"
  
  def opened order
    @order = order
    
    mail :subject => "Nova ordem aberta por #{@order.user.name}! [#{@order.id}]"
  end
  
  def closed order
    @order = order
    
    mail :subject => "Ordem enviada por #{@order.user.name}! [#{@order.id}]"
  end
end
