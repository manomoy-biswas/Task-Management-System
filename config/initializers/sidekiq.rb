Sidekiq.configure_server do |config|
  ActiveRecord::Base.establish_connection({ 
    adapter: "mysql2",
    database: "Task_Management_System_#{ENV["RAILS_ENV"]}",
    host: "db",
    port: "3306",
    username: "root",
    password: "root"
  })
end if Rails.env.development?