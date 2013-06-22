require 'spec_helper'

feature 'user sends donation', %q{
  As a user
  I want to send a donation to Greg
  so I can give him money for his excellent work
} do

  # AC
  # * I can specify a donation amount to send
  # * The donation is only sent once
  # * I am notified that the donation has been sent
  # * I must be logged in to send a donation

  let!(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  # scenario 'unauthenticated user visits donations page' do
  #   visit new_donation_path
  #   expect(current_path).to eql new_user_session_path
  # end

  scenario 'authenticated user sends a donation', :js => true do
    # sign_in user
    visit new_donation_path
    fill_in 'card_number', with: '4242424242424242'
    fill_in 'card_code', with: 123
    click_button 'Donate'
  end

end
