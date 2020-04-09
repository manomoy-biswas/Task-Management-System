
Admin = User.new(id: 1, name: "Admin", email: "admin@gmail.com", phone:"123456789", dob: "01-01-2000", password: "admin", password_confirmation: "admin", admin: true, hr: false).save(validate: false)

%w(Birthday Interview Training Exams Campus Event Hiring).each do |category|
  Category.new(name: category).save
end