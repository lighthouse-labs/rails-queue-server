class AddBackgroundImageFieldsToSections < ActiveRecord::Migration[5.0]
  def change
    add_column :sections, :background_image_url, :string
    add_column :sections, :background_image_darkness, :string
  end
end
