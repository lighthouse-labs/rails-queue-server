class AddRubricAndChecklistToProjects < ActiveRecord::Migration[5.0]
  def change
    # Eval criteria can change mid cohort, this allows us to track which
    # sha it's currently at
    # When a new eval is created against a project, its sha is copied
    # That way we can notify the evaluator if the critiera is old

    add_column :sections, :last_sha1, :string

    add_column :sections, :evaluation_rubric, :jsonb
    add_column :sections, :evaluation_guide, :text
    add_column :sections, :evaluation_checklist, :text

    add_index  :sections, :evaluation_rubric, using: :gin
  end
end
