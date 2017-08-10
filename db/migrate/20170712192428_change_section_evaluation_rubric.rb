class ChangeSectionEvaluationRubric < ActiveRecord::Migration[5.0]

  def up
    remove_index :sections, :evaluation_rubric
    change_column :sections, :evaluation_rubric, 'json USING CAST(evaluation_rubric AS json)'
  end

  def down
    change_column :sections, :evaluation_rubric, 'jsonb USING CAST(evaluation_rubric AS jsonb)'
    add_index :sections, :evaluation_rubric
  end

end
