# == Schema Information
#
# Table name: debts
#
#  id          :integer          not null, primary key
#  title       :string(255)      not null
#  description :string(200)
#  amount      :decimal(10, 2)   not null
#  paid        :boolean          default(FALSE), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'spec_helper'

describe Debt do
  describe "properties" do
    it { should respond_to(:title) }
    it { should respond_to(:description) }
    it { should respond_to(:amount) }
    it { should respond_to(:paid) }
  end

  describe "validations" do

    context "title" do
      it { should validate_presence_of(:title) }
    end

    context "paid" do
      it { should validate_presence_of(:paid) }
      describe "default" do
        it { should_not be_paid }
      end
    end

    context "description" do
      it { should_not validate_presence_of(:description) }
      it { should ensure_length_of(:description).is_at_most(200) }
    end

    context "amount" do
      it { should validate_presence_of(:amount) }
      it { should allow_value(1.23, 1, 1.1).for(:amount) }
      it { should_not allow_value(1.234, -1, 0, 'hello').for(:amount) }
    end

  end
end
