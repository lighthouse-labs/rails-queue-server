class CreateEvaluationTransitions < ActiveRecord::Migration
  def change
    create_table :evaluation_transitions do |t|
      t.string :to_state, null: false
      t.text :metadata, default: "{}"
      t.integer :sort_key, null: false
      t.integer :evaluation_id, null: false
      t.boolean :most_recent, null: false
      t.timestamps null: false
    end

    add_index(:evaluation_transitions,
              [:evaluation_id, :sort_key],
              unique: true,
              name: "index_evaluation_transitions_parent_sort")
    add_index(:evaluation_transitions,
              [:evaluation_id, :most_recent],
              unique: true,
              where: 'most_recent',
              name: "index_evaluation_transitions_parent_most_recent")
  end
end
