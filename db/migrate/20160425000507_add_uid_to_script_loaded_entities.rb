class AddUidToScriptLoadedEntities < ActiveRecord::Migration
  def change
    add_column :questions,  :uuid, :string
    add_index  :questions,  :uuid, unique: true

    add_column :sections,   :uuid, :string
    add_index  :sections,   :uuid, unique: true

    add_column :activities, :uuid, :string
    add_index  :activities, :uuid, unique: true
  end
end
