class AddStartDayToSections < ActiveRecord::Migration
  def change
    add_column :sections, :start_day, :string
  end
end
