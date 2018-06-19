class CreateWorkModuleItems < ActiveRecord::Migration[5.0]

  def change
    create_table :work_module_items do |t|
      t.string :uuid, null: false
      t.references :work_module, foreign_key: true
      t.references :activity, foreign_key: true
      t.integer :order
      t.boolean :archived

      t.timestamps
    end

    add_index :work_module_items, :uuid, unique: true
  end

end
