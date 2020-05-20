class AddWebhooksTable < ActiveRecord::Migration[5.0]
  def change
    create_table :webhooks do |t|
      t.references  :compass_instance, foreign_key: true
      t.string      :resource_type
      t.string      :model
      t.string      :action
      t.string      :url
      t.timestamps
    end
  end
end
