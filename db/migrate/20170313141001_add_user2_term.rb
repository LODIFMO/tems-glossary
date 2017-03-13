class AddUser2Term < ActiveRecord::Migration
  def change
    add_reference :terms, :user
  end
end
