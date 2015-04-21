# encoding: UTF-8

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
      mail.reply_to.should == ["ricardo"+"@"+"pedrocinefoto.com.br"]
    end
 
    #ensure that the sender is correct
    it 'has the correct sender address' do
      mail.from.should == ["ricardo"+"@"+"pedrocinefoto.com.br"]
    end
 
    #ensure that the @name variable appears in the email body
    it 'assigns @name' do
      mail.body.encoded.should match(order.user.first_name)
    end
    
  end
  
  
  describe "welcome with password instructions" do
    let!(:user){ Fabricate :user }
    subject{ UserMailer.welcome_with_password_instructions user }
    specify{ user.reset_password_token.should_not be_nil }
    
    #ensure that the subject is correct
    its(:subject) { should == "Seu cadastro já está pronto! Abra e veja como acessar..." }
    
    #ensure that the receiver is correct
    its(:to){ should == [user.email] }
    
    #ensure that the receiver is correct
    its(:reply_to){ should == ["ricardo"+"@"+"pedrocinefoto.com.br"] }
    
    #ensure that the sender is correct
    its(:from){ should == ["ricardo"+"@"+"pedrocinefoto.com.br"] }
    
    #ensure the reset password token in the message
    its(:"body.encoded"){ should match user.reset_password_token.to_s }
    
  end

end
