module OrdersHelper
  
  def t_status status
    t "order.status.#{status}"
  end
    
end
