require 'spec_helper'

describe Donation do

  describe "properties" do
    it { should respond_to(:email) }
    it { should respond_to(:name) }
    it { should respond_to(:amount) }
  end

  describe "validations" do
    it { should have_valid(:email).when('greg@greg.com')}
    it { should_not have_valid(:email).when(nil)}

    it { should have_valid(:amount).when(50)}
    it { should_not have_valid(:amount).when(nil, 0, -1)}
  end

  describe ".save_with_payment" do

    let(:donation) { FactoryGirl.create(:donation) }

    it "creates a charge if the info is valid" do
      before_count = Donation.count
      token = Stripe::Token.create(
          :card => {
          :number => "4242424242424242",
          :exp_month => 6,
          :exp_year => 2014,
          :cvc => 123
        }
      )
      donation.stripe_card_token = token.id
      donation.save_with_payment
      expect(Donation.count).to eql(before_count+1)
    end

    it "does not create a charge if the info is invalid" do
      donation.stripe_card_token = 'tok_blarg'
      expect{donation.save_with_payment}.to raise_error
    end
  end
end
