# encoding: utf-8

class Admin::OrdersController < Admin::ApplicationController

  # GET /admin/orders
  # GET /admin/orders.json
  def index
    @status = params[:status]
    @orders = Order.last_updated.page params[:page]
    @orders = @orders.where status: @status if @status
  end

  # GET /admin/orders/1
  # GET /admin/orders/1.json
  def show
    @order = Order.includes(:user).find(params[:id])
    @less_than_a_day = (Time.now - @order.created_at) > 1.day

    @total_count = @order.photos.sum &:count

    @photos = @order.photos.group_by do |photo|
      {
        paper:    photo.specification.paper,
        border:   photo.border,
        margin:   photo.margin,
        product:  photo.product
      }
    end

    respond_to do |format|
      format.html
      format.pdf { render layout: 'pdf.html' }
    end
  end

  def download
    @order = Order.find params[:id]

    originals = !params[:originals].nil?

    @order.compressed originals: originals do |file|
      @order.update_status Order::CATCHING
      send_data file.read, filename: @order.tmp_zip_identifier(human: true)
      @order.update_status Order::CAUGHT
    end

  end

  # GET /admin/orders/new
  # GET /admin/orders/new.json
  def new
    @order = Order.new
  end

  # GET /admin/orders/1/edit
  def edit
    @order = Order.find(params[:id])
  end

  # POST /admin/orders
  # POST /admin/orders.json
  def create
    @order = Order.new(params[:order])

    respond_to do |format|
      if @order.save
        format.html { redirect_to admin_order_path(@order), notice: 'Order was successfully created.' }
      else
        format.html { render action: "new" }
      end
    end
  end

  # PUT /admin/orders/1
  # PUT /admin/orders/1.json
  def update
    @order = Order.find(params[:id])

    respond_to do |format|
      if @order.update_attributes(params[:order])
        format.html { redirect_to admin_order_path(@order), notice: 'Order was successfully updated.' }
      else
        format.html { render action: "edit" }
      end
    end
  end

  # DELETE /admin/orders/1
  # DELETE /admin/orders/1.json
  def destroy
    @order = Order.find(params[:id])
    @order.destroy

    respond_to do |format|
      format.html { redirect_to admin_orders_url, notice: 'Ordem de serviço excluída com sucesso.' }
    end
  end
end
