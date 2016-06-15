class CreateDeployments < ActiveRecord::Migration
  def change
    create_table :deployments do |t|
      t.references :content_repository, index: true, foreign_key: true
      t.string :sha
      t.string :status, default: 'started'
      t.string :log_file
      t.string :summary_file
      t.timestamp :completed_at
      t.timestamps null: false
    end
  end
end
