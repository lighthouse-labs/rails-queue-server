class AddSlackAlertInfoToLocations < ActiveRecord::Migration[5.0]
  def up
    add_column :locations, :slack_channel, :string
    add_column :locations, :slack_username, :string

    Location.where(name: ['Vancouver', 'Kelowna', 'Victoria', 'Calgary']).each do |l|
      # shouldn't fail validation but if it does it's okay (graceful)
      l.update slack_channel: '#compass-queue-alerts', slack_username: '@rosy'
    end

    Location.where(name: ['Toronto', 'Montreal', 'Halifax']).each do |l|
      # shouldn't fail validation but if it does it's okay (graceful)
      l.update slack_channel: '#compass-queue-alerts', slack_username: '@goldy'
    end
  end

  def down
    remove_column :locations, :slack_channel
    remove_column :locations, :slack_username
  end
end
