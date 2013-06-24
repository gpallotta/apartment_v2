class Group < ActiveRecord::Base
  before_validation :create_identifier

  has_many :users, dependent: :destroy, inverse_of: :group
  has_many :chores, dependent: :destroy, inverse_of: :group
  has_many :managers, dependent: :destroy, inverse_of: :group

  validates_presence_of :identifier
  validates_uniqueness_of :identifier

  attr_accessible :identifier

  def cycle_chores
    users_arr = []
    chores.each { |c| users_arr << c.user}
    users_arr << users_arr.shift
    chores.count.times do |i|
      chores[i].user = users_arr[i]
      chores[i].save
    end
  end

  private

  def create_identifier
    if self.identifier == '' or self.identifier == nil
      self.identifier = "#{Faker::Internet.domain_word}-#{Faker::Internet.domain_word}"
    end
  end

  def self.delete_empty
    Group.all.each do |g|
      if g.users.count == 0
        g.destroy
      end
    end
  end



end
