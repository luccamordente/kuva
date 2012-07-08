require "spec_helper"

describe OrderMailer do

  describe "opened" do
    let(:order) { Fabricate :order }
    let(:mail) { OrderMailer.opened(order) }
 
    #ensure that the subject is correct
    it 'renders the subject' do
      mail.subject.should == "Nova ordem aberta por #{order.user.name}! [#{order.id}]"
    end
 
    #ensure that the receiver is correct
    it 'renders the receiver email' do
      mail.to.should == ["staff@kuva.com"]
    end
 
    #ensure that the sender is correct
    it 'renders the sender email' do
      mail.from.should == ["notification@kuva.com"]
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
    let(:mail) { OrderMailer.closed(order) }
 
    #ensure that the subject is correct
    it 'renders the subject' do
      mail.subject.should == "Ordem enviada por #{order.user.name}! [#{order.id}]"
    end
 
    #ensure that the receiver is correct
    it 'renders the receiver email' do
      mail.to.should == ["staff@kuva.com"]
    end
 
    #ensure that the sender is correct
    it 'renders the sender email' do
      mail.from.should == ["notification@kuva.com"]
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

end
