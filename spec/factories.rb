FactoryGirl.define do
  factory :user do
    #create sequence to have unique users
    sequence(:name)  { |n| "Person #{n}" }
    sequence(:username)  { |n| "username#{n}" }
    sequence(:email) { |n| "person_#{n}@example.com"} 
    password "foobar"
    active true
    password_confirmation "foobar"
    factory :admin do
      admin true
    end
    factory :non_active_user do
      active false
    end
  end

  factory :micropost do
    content "Lorem ipsurm yo momma"
    user
  end
end