class AddUnlockOnDayToWorkbooks < ActiveRecord::Migration[5.0]
  def change
    add_column :workbooks, :unlock_on_day, :string, limit: 5
  end
end
