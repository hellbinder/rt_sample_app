# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  email           :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  password_digest :string(255)
#  remember_token  :string(255)
#  admin           :boolean          default(FALSE)
#

class User < ActiveRecord::Base
  attr_accessible :email, :name, :password, :password_confirmation
  validates_presence_of :name, :email, :password_confirmation
  validates_length_of :name, maximum: 50
  validates_length_of :password, minimum: 6
  has_secure_password #rails password module. Must invlide password_digest column
  has_many :microposts, dependent: :destroy
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates_format_of :email, with: VALID_EMAIL_REGEX
  validates_uniqueness_of :email, case_sensitive: false
  before_save { email.downcase! }
  before_save :create_remember_token
  ##NEXT COUPLE OF LINES ALSO WORK!
    #before_save :downcase_email
    #def downcase_email
      #self.email = email.downcase 
    #end
  ##END

  def feed
    #I'm pretty sure there is a better way to do this.
    Micropost.where("user_id = ?", id)
  end
  
private

  def create_remember_token
    self.remember_token = SecureRandom.urlsafe_base64
  end
  
end
