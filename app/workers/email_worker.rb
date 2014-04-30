class EmailWorker
  include Sidekiq::Worker

#Have to make sure that the information passed through is thread safe.
#Bad practice to actually pass in the whole object, pass the id and get the object in the process itself.
#THIS IS NOT NEEDED. BY DEFAULT THE DELAY MAILER CAN BE USED!...keeping it for reference.
  def send_signup_confirmation(user_id)
    user = User.find(user_id)
    UserMailer.signup_confirmation(user).deliver
  end

  def send_follower_confirmation(current_user_id, user_id)
    current_user = User.find(current_user_id)
    user = User.find(user_id)
    UserMailer.follower_confirmation(current_user, user).deliver
  end
end