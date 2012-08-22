module OrdersHelper
  
  def labeled_status order
    status = order.status
    return nil unless status
    label = order.simple_status
    klass = nil
    case status
    when Order::PROGRESS
      klass = "warning"
    when Order::CLOSED
      klass = "success"
    when Order::CATCHING
      klass = "info"
    when Order::CAUGHT
      klass = "inverse"
    when Order::READY
      klass = "inverse"
    when Order::DELIVERED
      klass = "inverse"
    end
    %Q{<span class="label #{klass ? "label-#{klass}" : ""}">#{label}</span>}.html_safe
  end
    
end
