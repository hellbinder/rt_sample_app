namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    make_users
    make_micropost
    make_relationships
  end

  def make_users
    admin = User.create!(name: "Miguel Martorell",
                 email: "miguel_1216@yahoo.com",
                 username:"mmartorell",
                 password: "foobar",
                 password_confirmation: "foobar")
    admin.toggle!(:admin)
    99.times do |n|
      name  = Faker::Name.name
      nameSplit = name.split()
      username = nameSplit[0][0].downcase + nameSplit[1].downcase
      if username.length > 5
        email = "example-#{n+1}@railstutorial.org"
        password  = "password"
        created_user = User.create!(name: name,
                     email: email,
                     username: username,
                     password: password,
                     password_confirmation: password)
      end
    end
  end

  def make_micropost
    users = User.all(limit: 6)
    50.times do |n|
      users.each { |user| user.microposts << Micropost.new(content: Faker::Lorem.sentence(11)) }
     end
  end

  def make_relationships
    users = User.all
    user = users.first
    followed_users = users[2..50]
    followers      = users[3..40]
    followed_users.each { |followed| user.follow!(followed) } 
    followers.each { |follower| follower.follow!(user) } 
  end

end