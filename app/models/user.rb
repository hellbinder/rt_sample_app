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
  attr_accessible :email, :name, :password, :password_confirmation, :username
  validates_presence_of :name, :username, :email, :password_confirmation # if i take user name off, still apsses presence test.
  validates_length_of :username, maximum: 15, minimum: 6
  validates_length_of :name, maximum: 50
  validates_length_of :password, minimum: 6
  has_secure_password #rails password module. Must include password_digest column
  has_many :microposts, dependent: :destroy
  #-------------------------------RELATIONSHIP STUFF----------------#
  #create normal relationship(followed_users)
  has_many :relationships, foreign_key: "follower_id", dependent: :destroy
  #looks for the followed_id in the relationship table and created the followed_user attribute
  has_many :followed_users, through: :relationships, source: :followed 
  #create reverse_relationship..(followers)
  #Note that we actually have to include the class name for this association, i.e.,
  #because otherwise Rails would look for a ReverseRelationship class, which doesn’t exist.
  has_many :reverse_relationships, class_name: "Relationship", foreign_key: "followed_id", dependent: :destroy
  has_many :followers, through: :reverse_relationships, source: :follower
  #-----------------------------END RELATIONSHIP STUFF----------------#
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates_format_of :email, with: VALID_EMAIL_REGEX
  validates_uniqueness_of :email, case_sensitive: false
  before_save { email.downcase! }
  before_save :create_remember_token
  before_save :create_email_confirmation_hash

  ##NEXT COUPLE OF LINES ALSO WORK!
    #before_save :downcase_email
    #def downcase_email
      #self.email = email.downcase 
    #end
  ##END

  def feed
    #I'm pretty sure there is a better way to do this.
    Micropost.from_users_followed_by(self)
  end
  
  def following?(other_user)
    relationships.find_by_followed_id(other_user.id)
  end

  def follow!(other_user)
    relationships.create(followed_id: other_user.id)

    #other_user.followers << self
  end

  def unfollow!(other_user)
    relationships.find_by_followed_id(other_user.id).destroy
  end

  def reply_username
    "@#{username}"
  end

  def self.search(search)
    #NEED to return a scope to be able to call more methods such as paginate.
    if search
      where("name LIKE :search OR username LIKE :search", search: "#{search}%")
    else
      scoped
    end
  end

private

  def create_remember_token
    self.remember_token = SecureRandom.urlsafe_base64
  end
  
  def create_email_confirmation_hash
    self.confirmation_hash = SecureRandom.urlsafe_base64 if self.new_record?
  end
end