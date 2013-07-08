require 'spec_helper'

feature 'user viewing information', %q{
  As a user
  I want to view my information on the site
  so I can see if it is up to date
} do

  # AC:
  # I can view my information when I am logged in

  given(:user) { FactoryGirl.create(:user) }

  scenario 'user visits profile page' do
    sign_in user
    visit user_path(user)
    expect(page).to have_content(user.name)
    expect(page).to have_content(user.email)
    expect(page).to have_content(user.group.identifier)
    expect(page).to have_link('Edit', href: edit_user_registration_path(user))
    expect(page).to have_content('weekly email summaries')
    expect(page).to have_content('daily email summaries')
  end

  scenario 'user visits profile page of another user' do
    user2 = FactoryGirl.create(:user)
    sign_in user2
    visit user_path(user)
    expect(current_path).to eql user_root_path
  end

end
