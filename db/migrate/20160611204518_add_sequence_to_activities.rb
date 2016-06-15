class AddSequenceToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :sequence, :integer
    add_index :activities, :sequence
  end
end
