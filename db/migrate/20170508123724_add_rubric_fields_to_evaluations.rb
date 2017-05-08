class AddRubricFieldsToEvaluations < ActiveRecord::Migration[5.0]
  def change
    # Eval criteria can change mid cohort, this allows us to track which
    # sha it's currently at
    # When a new eval is created against a project, its sha is copied
    # That way we can notify the evaluator if the critiera is old
    add_column :evaluations, :last_sha1, :string

    # snapshot of the same content from sections (projects)
    # this is b/c evaluation criteria can change, and we want to capture
    # what it was at the time of submission, otherwise it's unfair and/or inaccurate
    add_column :evaluations, :evaluation_rubric, :jsonb
    add_column :evaluations, :evaluation_guide, :text
    add_column :evaluations, :evaluation_checklist, :text

    add_index  :evaluations, :evaluation_rubric, using: :gin

    add_column :evaluations, :rubric_scores, :jsonb
    add_index  :evaluations, :rubric_scores, using: :gin
  end
end
