class CreateUserStatusLogs < ActiveRecord::Migration[5.0]
  def change
    create_table :user_status_logs do |t|
      t.string      :user_uid
      t.datetime    :created_at, null: false
      t.string      :status
    end
  end
end
