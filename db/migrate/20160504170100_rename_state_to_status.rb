class RenameStateToStatus < ActiveRecord::Migration
  def change
    rename_column :evaluations, :state, :status
  end
end
