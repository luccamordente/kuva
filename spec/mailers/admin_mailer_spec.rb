require "spec_helper"

describe AdminMailer do

  describe "opened" do
    let(:order) { Fabricate :order }
    let(:mail) { AdminMailer.order_opened(order) }

    #ensure that the subject is correct
    it 'renders the subject' do
      mail.subject.should == "Nova ordem aberta por #{order.user.name}! [#{order.id}]"
    end

    #ensure that the receiver is correct
    it 'renders the receiver email' do
      mail.to.should == ["luccamordente@gmail.com", "heitorsalazar@gmail.com", "ricardomordente@gmail.com"]
    end

    #ensure that the sender is correct
    it 'renders the sender email' do
      mail.from.should == ["pedrocinefoto@gmail.com"]
    end

    #ensure that the @name variable appears in the email body
    it 'assigns @name' do
      mail.body.encoded.should match(order.user.name)
    end

    #ensure that the @confirmation_url variable appears in the email body
    it 'displays the admin url' do
      mail.body.encoded.should match admin_root_url
    end
  end

  describe "closed" do
    let(:order) { Fabricate :order }
    let(:mail) { order.update_status Order::CLOSED; AdminMailer.order_closed(order) }

    #ensure that the subject is correct
    it 'renders the subject' do
      mail.subject.should == "Ordem enviada por #{order.user.name}! [#{order.id}]"
    end

    #ensure that the receiver is correct
    it 'renders the receiver email' do
      mail.to.should == ["luccamordente@gmail.com", "heitorsalazar@gmail.com", "ricardomordente@gmail.com"]
    end

    #ensure that the sender is correct
    it 'has the correct sender address' do
      mail.from.should == ["pedrocinefoto@gmail.com"]
    end

    #ensure that the @name variable appears in the email body
    it 'assigns @name' do
      mail.body.encoded.should match(order.user.name)
    end

    #ensure that the @confirmation_url variable appears in the email body
    it 'displays the admin url' do
      mail.body.encoded.should match admin_order_url(order.id)
    end
  end

end
