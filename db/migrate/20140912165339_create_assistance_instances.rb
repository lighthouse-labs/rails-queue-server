class CreateAssistanceInstances < ActiveRecord::Migration
  def change
    create_table :assistances do |t|
      t.integer :assistor_id

      t.datetime :start_at
      t.datetime :end_at

      t.text :notes

      t.timestamps
    end
  end
end
