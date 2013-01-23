require 'spec_helper'

describe OrdersController do

  describe "anonymous user" do
    specify { subject.current_user.should be_nil }

    it "should not have a current_user" do
      get :new
      subject.current_user.should be_nil
    end

    # it "should have a current_user" do
    #   get :index
    #   subject.current_user.should_not be_nil
    # end
    #
    # it "should use the same user between subsequent requests" do
    #   get :index
    #   first_user_email = subject.current_user.email
    #   get :index
    #   first_user_email.should == subject.current_user.email
    #   pending "teste não está funcionando!"
    # end
    #
    # it "should be anonymous" do
    #   get :index
    #   subject.current_user.should be_anonymous
    # end
  end


  describe "registered user" do

    login_user

    describe "new" do
      it "should not create a new order anymore" do
        expect { get :new }.not_to change(Order, :count)
      end

      it "loads photos specs" do
        get :new
        specs = assigns[:specs]
        specs[:paper].should_not be_nil
        Specification::PAPERS.each { |paper| specs[:paper] == paper }
      end

      it "loads the products" do
        get :new
        assigns[:products].should_not be_nil
      end
    end

    describe "open" do
      it "creates a new order" do
        expect { post :create }.to change(Order, :count).by(1)
      end

      it "creates a new order for current user each time" do
        expect { 2.times { post :create } }.to change(current_user.orders, :count).by 2
      end

      it "returns the order id and sequence" do
        post :create
        res = ActiveSupport::JSON.decode(response.body)
        res['id'      ].should_not be_nil
        res['sequence'].should_not be_nil
      end
    end

    describe "update" do
      it "updates unprotected attributes" do
        order = Fabricate :order, user_id: current_user.id, observations: nil
        put :update, id: order.id, order: { observations: "teste" }
        order.reload.observations.should_not be_nil
      end

      it "does not update protected attributes" do
        order = Fabricate :order, user_id: current_user.id
        expect { put :update, id: order.id, order: { user_id: Fabricate(:user).id } }.not_to change(order, :user_id)
      end
    end


    describe "close" do
      let!(:order){ Fabricate :order, user_id: current_user.id }

      specify { order.user_id.should == current_user.id }

      it "closes an opened order" do
        post :close, id: order.id
        order.reload.status.should == Order::CLOSED
      end

      it "updates the order price again to make sure it's correct" do
        order.update_attribute :price, 100000
        post :close, id: order.id
        order.reload.price.should_not == 100000
      end

    end


    describe "cancel" do
      let!(:order){ Fabricate :order, user_id: current_user.id }

      it "cancels the order" do
        post :cancel, id: order.id
        order.reload.status.should == Order::CANCELED
      end

    end

  end



end
