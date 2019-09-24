class DropActivityMessages < ActiveRecord::Migration[5.0]
  def change
    drop_table :activity_messages
  end
end
