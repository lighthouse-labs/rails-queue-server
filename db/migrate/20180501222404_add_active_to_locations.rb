class AddActiveToLocations < ActiveRecord::Migration[5.0]
  def up
    add_column :locations, :active, :boolean, default: true

    Location.where(name: %w{Halifax Kelowna London}).update_all(active: false)
  end
  def down
    remove_column :locations, :active, :boolean, default: true
  end
end
