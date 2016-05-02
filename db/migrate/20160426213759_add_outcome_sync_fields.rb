class AddOutcomeSyncFields < ActiveRecord::Migration
  def change
    add_column :outcomes,  :uuid, :string
    add_index  :outcomes,  :uuid, unique: true

    add_column :outcomes, :taxonomy, :string

    add_column :outcomes, :importance, :string

    add_column :skills,   :uuid, :string
    add_index  :skills,   :uuid, unique: true

    add_column :categories, :uuid, :string
    add_index  :categories, :uuid, unique: true
  end
end
