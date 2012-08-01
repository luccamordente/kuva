require "spec_helper"

describe UserMailer do

  describe "closed" do
    let!(:order) { Fabricate :order }
    let (:mail)  { order.update_status Order::CLOSED; UserMailer.order_closed(order) }
 
    #ensure that the subject is correct
    it 'renders the subject' do
      mail.subject.should == "Recebemos suas fotos! Abra para instruções..."
    end
 
    #ensure that the receiver is correct
    it 'has the correct receiver address' do
      mail.to.should == [order.user.email]
    end
    
    #ensure that the receiver is correct
    it 'has the correct reply to address' do
      mail.reply_to.should == ["ricardo@pedrocinefoto.com.br"]
    end
 
    #ensure that the sender is correct
    it 'has the correct sender address' do
      mail.from.should == ["ricardo@pedrocinefoto.com.br"]
    end
 
    #ensure that the @name variable appears in the email body
    it 'assigns @name' do
      mail.body.encoded.should match(order.user.first_name)
    end
    
  end

end
