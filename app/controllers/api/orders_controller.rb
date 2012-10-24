class Api::OrdersController < Api::BaseController
  respond_to :json

  def download
    @order = Order.find params[:id]

    @order.compressed do |file|
      @order.update_status Order::CATCHING
      send_data file.read, filename: "#{@order.id}.zip"
      @order.update_status Order::CAUGHT
    end
  end

  def closed
    respond_with Order.where(status: Order::CLOSED).order_by(:closed_at.asc).only(:_id).map(&:_id)
  end

end
