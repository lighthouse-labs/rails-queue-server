class AddStretchToSections < ActiveRecord::Migration[5.0]
  def change
    add_column :sections, :stretch, :boolean
  end
end
