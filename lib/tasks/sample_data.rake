namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    admin = User.create!(name: "Miguel Martorell",
                 email: "miguel_1216@yahoo.com",
                 password: "foobar",
                 password_confirmation: "foobar")
    admin.toggle!(:admin)
    99.times do |n|
      name  = Faker::Name.name
      email = "example-#{n+1}@railstutorial.org"
      password  = "password"
     created_user = User.create!(name: name,
                   email: email,
                   password: password,
                   password_confirmation: password)
     25.times do |n|
      created_user.microposts << Micropost.new(content: Faker::Lorem.sentence(11))
     end
    end
  end
end