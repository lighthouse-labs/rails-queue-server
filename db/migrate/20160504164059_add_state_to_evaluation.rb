class AddStateToEvaluation < ActiveRecord::Migration
  def change
    add_column :evaluations, :state, :string
  end
end
