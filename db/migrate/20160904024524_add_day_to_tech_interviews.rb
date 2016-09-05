class AddDayToTechInterviews < ActiveRecord::Migration[5.0]
  def change
    add_column :tech_interviews, :day, :string
  end
end
