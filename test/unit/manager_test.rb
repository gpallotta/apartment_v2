# == Schema Information
#
# Table name: managers
#
#  id           :integer          not null, primary key
#  title        :string(255)      not null
#  name         :string(255)      not null
#  phone_number :string(255)      not null
#  address      :string(255)      not null
#  group_id     :integer          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

require 'test_helper'

class ManagerTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
