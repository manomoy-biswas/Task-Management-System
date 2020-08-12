FactoryBot.define do
  factory :invitation do
    name { Faker::Name.name }
    email {Faker::Internet.safe_email}
    invitation_token { "MyString" }
    status { "pending" }
  end
end
