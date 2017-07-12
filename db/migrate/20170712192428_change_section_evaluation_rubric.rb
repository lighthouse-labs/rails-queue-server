class ChangeSectionEvaluationRubric < ActiveRecord::Migration[5.0]

  def up
    remove_index :sections, :evaluation_rubric
    change_column :sections, :evaluation_rubric, :json
  end

  def down
    change_column :sections, :evaluation_rubric, :jsonb
    add_index :sections, :evaluation_rubric
  end

end
