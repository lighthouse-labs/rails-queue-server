class AddDisplayExactActivityDurationToPrograms < ActiveRecord::Migration[5.0]
  def change
    add_column :programs, :display_exact_activity_duration, :boolean
  end
end
