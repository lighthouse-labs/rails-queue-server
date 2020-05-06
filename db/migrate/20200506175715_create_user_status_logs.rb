class CreateUserStatusLogs < ActiveRecord::Migration[5.0]
  def change
    create_table :user_status_logs do |t|
      t.datetime    :created_at, null: false
      t.string      :status
      t.references  :user, foreign_key: true
    end
  end
end
