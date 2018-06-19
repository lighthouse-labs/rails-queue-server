class AddDescriptionToWorkbooks < ActiveRecord::Migration[5.0]
  def change
    add_column :workbooks, :description, :text
  end
end
