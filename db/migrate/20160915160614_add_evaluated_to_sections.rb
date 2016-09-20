class AddEvaluatedToSections < ActiveRecord::Migration[5.0]
  def change
    add_column :sections, :evaluated, :boolean
  end
end
