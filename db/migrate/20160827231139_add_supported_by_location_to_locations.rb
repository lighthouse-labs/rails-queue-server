class AddSupportedByLocationToLocations < ActiveRecord::Migration[5.0]
  def up
    add_column :locations, :satellite, :boolean
    add_column :locations, :supported_by_location_id, :integer
    add_index :locations, :supported_by_location_id

    say 'Updating satellite locations to have support locations'
    van = Location.find_by!(name: 'Vancouver')
    tor = Location.find_by!(name: 'Toronto')

    Location.where(name: %w{Kelowna Calgary Victoria}).update_all(supported_by_location_id: van.id, satellite: true)
    Location.where(name: %w{Halifax Montreal Ottawa}).update_all(supported_by_location_id: tor.id, satellite: true)

  end

  def down
    remove_column :locations, :supported_by_location_id
    remove_column :locations, :satellite
  end
end
