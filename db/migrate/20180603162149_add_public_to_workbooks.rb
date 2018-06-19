class AddPublicToWorkbooks < ActiveRecord::Migration[5.0]
  def change
    add_column :workbooks, :public, :boolean
  end
end
