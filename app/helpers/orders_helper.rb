module OrdersHelper

  def labeled_status order
    status = order.status
    return nil unless status
    label = order.simple_status
    label_with_status label, status
  end

  def label_with_status label, status
    klass = status_class status
    %Q{<span class="label #{klass ? "label-#{klass}" : ""}">#{label}</span>}.html_safe
  end

  def status_class status
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
    when Order::CANCELED
      klass = "important"
    end
  end

end
