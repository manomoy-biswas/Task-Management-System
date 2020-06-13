module UsersHelper
  def total_users
    User.count
  end
end