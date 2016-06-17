class AddEndDayToSections < ActiveRecord::Migration
  def change
    add_column :sections, :end_day, :string
  end
end
