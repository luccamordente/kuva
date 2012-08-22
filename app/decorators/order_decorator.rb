# coding: utf-8

module OrderDecorator
  
  # Statuses for human admins. e.g.:
  #  => "Em andamento"
  def simple_status
    I18n.t "order.status.#{status}"
  end

  # Statuses for human users. e.g.:
  #  => "Seu pedido foi enviado e fica pronto em 47 minutos."
  def humanized_status
    if sent? and promised_for.future?
      I18n.t "order.status.humanized.sent", remaining_time: remaining_time
    elsif sent? and promised_for.past?
      I18n.t "order.status.humanized.ready"
    else
      I18n.t "order.status.humanized.#{status}"
    end
  end
  
  # Depending on the status, generates a string like:
  #  => "Aberto em: 14/Ago/2012, 10:47h (aproximadamente 6 horas atrás)"
  def status_time
    which, time = * case status
      when Order::EMPTY, Order::PROGRESS                  then ["opened"   , created_at  ]
      when Order::CLOSED, Order::CATCHING, Order::CAUGHT  then ["sent"     , closed_at   ]
      when Order::READY                                   then ["ready"    , ready_at    ]
      when Order::DELIVERED                               then ["delivered", delivered_at]
      when Order::CANCELED                                then ["canceled" , canceled_at ]
    end
    "#{I18n.t("order.status.time.#{which}")} #{l(time, format: :medium)} (#{time_ago_in_words(time)})"
  end
  
  # Time remaining for promised time. e.g.:
  #  => "47 minutos"
  def remaining_time
    distance_of_time_in_words promised_for, Time.now
  end
  
private
  
  # Time ago in words with "ago"
  def time_ago_in_words *args
    "#{super} #{I18n.t("datetime.distance_in_words.ago")}"
  end
  
end
