# coding: utf-8

module OrderDecorator
  
  def simple_status
    I18n.t "order.status.#{status}"
  end

  def humanized_status
    if sent? and promised_for.future?
      I18n.t "order.status.humanized.sent", :remaining_time => remaining_time
    elsif sent? and promised_for.past?
      I18n.t "order.status.humanized.ready"
    else
      I18n.t "order.status.humanized.#{status}"
    end
  end
  
  def remaining_time
    distance_of_time_in_words Time.now, promised_for
  end
  
end
