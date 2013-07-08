require 'spec_helper'

describe User do

  include EmailSpec::Helpers
  include EmailSpec::Matchers

  let(:group) { FactoryGirl.create(:group) }
  let(:other_group) { FactoryGirl.create(:group) }
  let!(:other_user) { FactoryGirl.create(:user, group: other_group, name: 'Steve') }
  let!(:user1) { FactoryGirl.create(:user, group: group, name: 'Steve') }
  let(:user2) { FactoryGirl.create(:user, group: group) }
  let(:c1) { FactoryGirl.create(:claim, user_owed_to: user1, user_who_owes: user2) }
  let(:c2) { FactoryGirl.create(:claim, user_owed_to: user2, user_who_owes: user1) }
  let(:c3) { FactoryGirl.create(:claim, user_owed_to: other_user, user_who_owes: other_user) }

  describe "scope" do

    describe ".claims" do
      it { should respond_to(:claims) }
      it "returns all claims for user" do
        expect(user1.claims).to include(c1, c2)
        expect(user1.claims).not_to include(c3)
      end
    end

    describe ".unpaid_claims" do
      it "returns unpaid claims related to the user" do
        c2.update_attributes(paid: true)
        expect(user1.unpaid_claims).to include(c1)
        expect(user1.unpaid_claims).not_to include(c2)
      end
    end

    describe '.claims_to_receive' do
      it "returns claims that are owed to you" do
        expect(user1.claims_to_receive).to include(c1)
        expect(user1.claims_to_receive).not_to include(c2, c3)
      end
    end

    describe ".claims_to_pay" do
      it "returns claims that you owe to other users" do
        expect(user1.claims_to_pay).to include(c2)
        expect(user1.claims_to_pay).not_to include(c1, c3)
      end
    end

    describe ".subscribed_to_weekly_email" do
      it "returns users who are subscribed to the weekly email" do
        user2.update_attributes(receives_weekly_email: true)
        users = User.subscribed_to_weekly_email
        expect(users).to include(user2)
        expect(users).not_to include(user1)
      end
    end

    describe ".subscribed_to_daily_email" do
      it "returns users who are subscribed to the daily email" do
        user2.update_attributes(receives_daily_email: true)
        users = User.subscribed_to_daily_email
        expect(users).to include(user2)
        expect(users).not_to include(user1)
      end
    end

    describe ".claims_owed_and_created_today" do
      let!(:old_cl) { FactoryGirl.create(:claim, user_who_owes: user1,
                  user_owed_to: user2, created_at: Date.yesterday)}
      it "returns claims that were created today and are owed by the user" do
        claims = user1.claims_owed_and_created_today
        expect(claims).to include(c2)
        expect(claims).not_to include(old_cl)
      end
    end

  end

  describe "associations" do

    context "claims" do
      context "claims_to_receive" do
        it { should have_many(:claims_to_receive).dependent(:destroy) }
        it "returns only claims owed to the user" do
          expect(user1.claims_to_receive).to include(c1)
          expect(user1.claims_to_receive).not_to include(c2, c3)
        end
      end

      context "claims_to_pay" do
        it { should have_many(:claims_to_pay).dependent(:destroy) }
        it "returns only claims that the user owes" do
          expect(user1.claims_to_pay).to include(c2)
          expect(user1.claims_to_pay).not_to include(c1, c3)
        end
      end
    end

    context "activity" do
      context "activities_as_owner" do
        it { should have_many(:activities_as_owner).dependent(:destroy) }
      end

      context "activities_as_recipient" do
        it { should have_many(:activities_as_recipient).dependent(:destroy) }
      end
    end

    context "chores" do
      let(:c1) { FactoryGirl.create(:chore, user: user1)}
      let(:c2) { FactoryGirl.create(:chore, user: user2)}
      it { should have_many(:chores) }
      it "returns chores which belong to the user" do
        expect(user1.chores).to include(c1)
        expect(user1.chores).not_to include(c2)
      end
    end

    context "group" do
      it { should belong_to(:group) }
      it { should have_valid(:group).when(Group.new) }
      it { should_not have_valid(:group).when(nil) }
      it "returns the proper group" do
        expect(user1.group).to eql(group)
      end
    end

    context "comments" do
      let(:com1) { FactoryGirl.create(:comment, claim: c1, user: user1) }
      let(:com2) { FactoryGirl.create(:comment, claim: c1, user: user2) }
      it { should have_many(:comments).dependent(:destroy) }
      it "returns comments which belong to the user" do
        expect(user1.comments).to include(com1)
        expect(user1.comments).not_to include(com2)
      end
    end

  end

  describe "properties" do

    describe "name" do
      it { should respond_to(:name) }
      it { should_not have_valid(:name).when(nil, '') }
      it { should have_valid(:name).when('string') }
      context "uniqueness among group" do
        let!(:steve) { FactoryGirl.build(:user, group: group, name: 'Steve') }
        it "validates uniqueness of name amongst a group" do
          expect(steve).not_to be_valid
          expect(other_user).to be_valid
        end
      end
    end

    describe "email" do

      it { should respond_to(:email) }
      it { should_not have_valid(:email).when(nil, '', 'greg') }
      it { should have_valid(:email).when('greg@greg.com') }
      it { should validate_uniqueness_of(:email) }

      context "receives_weekly_email?" do
        it { should respond_to(:receives_weekly_email?) }
        it "is false by default" do
          expect(User.new.receives_weekly_email).to be_false
        end
      end

      context "receives_daily_email" do
        it { should respond_to(:receives_daily_email) }
        it "is false by default" do
          expect(User.new.receives_daily_email).to be_false
        end
      end
    end

    describe "password" do
      it { should respond_to(:encrypted_password) }
      it { should respond_to(:password)}
      it { should respond_to(:password_confirmation)}

      it { should_not have_valid(:password).when(nil, '', 'greg') }
      it { should have_valid(:password).when('password') }
      it { should validate_confirmation_of(:password) }
      it { should ensure_length_of(:password).is_at_least(8) }
    end

  end

  describe "methods" do

    describe ".register" do
      let(:user) { FactoryGirl.build(:user) }
      it "saves the user and sends an email if successful" do
        user.register
        expect(last_email.to).to include(user.email)
      end

      it "does not send an email if the save is unsuccessful" do
        user.password_confirmation = ''
        user.register
        expect(last_email).to be_nil
      end

    end

    describe ".delete_unaccepted_invitations" do

      let!(:regular_user) { FactoryGirl.create(:user) }
      let!(:unaccepted_user) do
        unaccepted_user = FactoryGirl.build(:user)
        unaccepted_user.invitation_token = 'greg1'
        unaccepted_user.invitation_sent_at = Time.now
        unaccepted_user.save
        unaccepted_user
      end
      let!(:accepted_user) do
        accepted_user = FactoryGirl.build(:user)
        accepted_user.invitation_token = 'greg3'
        unaccepted_user.invitation_sent_at = Time.now
        accepted_user.invitation_accepted_at = Time.now
        accepted_user.save
        accepted_user
      end

      before do
        Timecop.freeze(Date.today + 9)
      end

      after do
        Timecop.return
      end

      it "deletes users who have not accepted their invitation in 7 days" do
        User.delete_unaccepted_invitations
        unaccepted_user = unaccepted_user
        expect(unaccepted_user).to be_nil
        expect(accepted_user).not_to be_nil
      end
    end
  end

end
