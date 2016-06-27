class AddBlurbToSections < ActiveRecord::Migration
  def change
    add_column :sections, :blurb, :text
  end
end
