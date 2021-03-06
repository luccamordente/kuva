class Api::OrdersController < Api::BaseController

  def show
    @order = Order.includes(:user).find(params[:id])

    @total_count = @order.photos.not_failed.sum &:count

    @photos = @order.photos.not_failed.group_by do |photo|
      {
        paper:    photo.specification.paper,
        border:   photo.border,
        margin:   photo.margin,
        product:  photo.product
      }
    end

    respond_to do |format|
      format.html { render layout: false }
      format.pdf  { render layout: false }
    end
  end

  def download
    @order = Order.good_to_catch.find params[:id]
    @order.update_status Order::CATCHING

    @order.compressed do |file|
      send_data file.read, filename: @order.tmp_zip_identifier
      @order.update_status Order::CAUGHT
    end
  rescue Mongoid::Errors::DocumentNotFound => exception
    error 410, "Order cannot be downloaded"
  rescue => e
    @order.update_status Order::RECATCH
    raise e
  end

  def closed
    ids = Order.good_to_catch.order_by(:closed_at.asc).only(:_id, :sequence).map{ |order| { id: order.id, name: order.identifier(human: true) } }
    respond_to do |format|
      format.json { render json: ids }
    end
  end

end
