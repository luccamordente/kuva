module OrderMacros
  
  def orders_with_each_status statuses, &block  
    statuses.each do |status|
      status = "Order::#{status}".constantize
      order = Fabricate :order
      order.update_status status
      yield order, status
    end
  end
  
end