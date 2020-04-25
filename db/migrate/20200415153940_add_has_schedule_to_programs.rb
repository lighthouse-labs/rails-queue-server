class AddHasScheduleToPrograms < ActiveRecord::Migration[5.0]
  def change
    add_column :programs, :has_schedule, :boolean, default: true
  end
end
