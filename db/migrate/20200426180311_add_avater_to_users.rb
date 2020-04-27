class AddAvaterToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :avater, :string
  end
end
