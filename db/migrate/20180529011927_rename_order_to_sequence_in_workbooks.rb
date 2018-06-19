class RenameOrderToSequenceInWorkbooks < ActiveRecord::Migration[5.0]
  def change
    rename_column :work_modules, :order, :sequence
    rename_column :work_module_items, :order, :sequence
  end
end
