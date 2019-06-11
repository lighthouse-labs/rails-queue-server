class AddBackgroundImageSupportToActivities < ActiveRecord::Migration[5.0]
  def change
    add_column :activities, :background_image_url, :string
    add_column :activities, :background_image_darkness, :string
  end
end
