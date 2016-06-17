class AddNotesToEvaluation < ActiveRecord::Migration
  def change
    add_column :evaluations, :notes, :text
  end
end
