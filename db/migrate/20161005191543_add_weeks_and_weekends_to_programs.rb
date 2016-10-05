class AddWeeksAndWeekendsToPrograms < ActiveRecord::Migration[5.0]
  def up
    add_column :programs, :weeks, :integer
    add_column :programs, :weekends, :boolean
    add_column :programs, :curriculum_unlocking, :string
    Program.update_all(
      weeks: (ENV['WEEKS'] || 8).to_i,
      weekends: ENV['WEEKENDS'] ? ENV['WEEKENDS'] == 'true' : false,
      curriculum_unlocking: ENV['CURRICULUM_UNLOCKING'] || 'daily'
    )
  end

  def down
    remove_column :programs, :weeks
    remove_column :programs, :weekends
  end
end
