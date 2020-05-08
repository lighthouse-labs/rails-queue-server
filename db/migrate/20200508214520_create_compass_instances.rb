class CreateCompassInstances < ActiveRecord::Migration[5.0]
  def change
    create_table :compass_instances do |t|
      t.string    :name
      t.jsonb     :settings
      t.string    :database
      t.string    :type
      t.string    :key
    end
  end
end
