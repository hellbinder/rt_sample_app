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
end
