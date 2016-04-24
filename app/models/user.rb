class User < ActiveRecord::Base

  validates :name, presence: true
  validates :mid, presence: true
  validates :level, presence: true
  validates :mid, uniqueness: true

  scope :by_mid, ->(id) { where(mid: id) }

  def self.create(mid, name, level)
    User.transaction do
      user = User.new
      user.attributes = {name: name, mid: mid, level: level}
      user.save!
    end
    return true
  rescue => e
    return false
  end

end
