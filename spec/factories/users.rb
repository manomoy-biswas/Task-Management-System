FactoryBot.define do
  factory :admin, class: User do
    name { Faker::Name.name }
    email {"arnab.roy@kreeti.com"}
    phone  {rand(7000000000..9999999999)}
    dob {"01-01-1996"}
    password_digest {"admin"}
    admin {true}
    hr {false}
    auth_token {"wqeerfdt123"}
  end

  factory :hr, class: User do
    name { Faker::Name.name }
    email {Faker::Internet.safe_email}
    phone  {rand(7000000000..9999999999)}
    dob {"17-07-1995"}
    admin {false}
    hr {true}
  end

  factory :employee, class: User do
    name { Faker::Name.name }
    email {Faker::Internet.safe_email}
    phone  {rand(7000000000..9999999999)}
    dob {"20-10-1988"}
    admin {false}
    hr {false}
  end
end
