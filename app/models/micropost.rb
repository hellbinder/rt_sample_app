# == Schema Information
#
# Table name: microposts
#
#  id         :integer          not null, primary key
#  content    :string(255)
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Micropost < ActiveRecord::Base

  attr_accessible :content #user id should not be accessible. prone to malicious attacks
  validates_presence_of :user_id, message: "User can't be blank"
  validates_presence_of :content
  validates_length_of :content, maximum: 140, message: "Maximum of 140 characters is allowed"
  belongs_to :user
  default_scope order: "microposts.created_at DESC"


  #Notice the self meaning it's a static from the main class. Not an instance
  def self.from_users_followed_by(user)

    #doesn't scale well
    #followed_user_ids = user.followed_user_ids 
    #where("user_id IN (?) OR user_id = ?", followed_user_ids, user)
    #UPDATED VERSION
    followed_user_ids = "SELECT followed_id from relationships
                         WHERE follower_id = :user_id"
    where("user_id IN (#{followed_user_ids}) or user_id = :user_id", 
          user_id: user)
  end
end
