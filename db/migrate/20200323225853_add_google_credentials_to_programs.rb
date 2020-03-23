class AddGoogleCredentialsToPrograms < ActiveRecord::Migration[5.0]
  def change
    enable_extension "hstore"
    add_column :programs, :google_app_credentials, :hstore
  end
end