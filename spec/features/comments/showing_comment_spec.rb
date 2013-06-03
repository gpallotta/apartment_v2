require 'spec_helper'

describe "viewing comments" do

  extend CommentsHarness
  create_factories_and_sign_in

  let!(:com2) { FactoryGirl.create(:comment, user: user2, claim: cl) }

  before { visit claim_path(cl) }

  it "shows all comments for the claim" do
    expect(page).to have_content(com.content)
    expect(page).to have_content(com2.content)
  end
  it "shows who wrote the comment" do
    expect(page).to have_content(com.user.name)
    expect(page).to have_content(com2.user.name)
  end
  it "shows comments with the oldest first" do
    expect(page.body.index(com.content)).to be < page.body.index(com2.content)
  end
  it "only shows edit links for your comments" do
    expect(page).not_to have_link("Edit Comment", href: edit_comment_path(com2))
  end

end