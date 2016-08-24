class CreatePrepAssistanceRequests < ActiveRecord::Migration
  def change
    create_table :prep_assistance_requests do |t|
      t.datetime :created_at

      t.timestamps null: false
    end
  end
end
