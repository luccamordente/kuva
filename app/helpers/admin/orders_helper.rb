module Admin::OrdersHelper
  
  def labeled_status status
    return nil unless status
    label = t "order.status.#{status}"
    klass = nil
    case status
    when :progress
      klass = "warning"
    when :catching
      klass = "info"
    when :caught
      klass = "important"
    when :closed
      klass = "success"
    when :ready
      klass = "success"
    when :delivered
      klass = "inverse"
    end
    %Q{<span class="label #{klass ? "label-#{klass}" : ""}">#{label}</span>}.html_safe
  end
  
end
