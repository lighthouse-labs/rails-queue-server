class AddStretchToWorkModuleItems < ActiveRecord::Migration[5.0]
  def change
    add_column :work_module_items, :stretch, :boolean
  end
end
