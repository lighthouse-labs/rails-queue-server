class AddUrlToEvaluations < ActiveRecord::Migration
  def change
    add_column :evaluations, :url, :string
  end
end
