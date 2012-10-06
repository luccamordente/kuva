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

    describe "open" do
      it "opens a new order" do
        get :new
        order = assigns[:order]
        order.should_not be_nil
        order.should be_persisted
        order.user_id.should == current_user.id
      end

      it "creates a new order for current user each time" do
        expect { 2.times { get :new } }.to change(current_user.orders, :count).by 2
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


    describe "close" do
      let!(:order){ Fabricate :order, user_id: current_user.id }

      specify { order.user_id.should == current_user.id }

      it "closes an opened order" do
        post :close, id: order.id
        order.reload.status.should == Order::CLOSED
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
