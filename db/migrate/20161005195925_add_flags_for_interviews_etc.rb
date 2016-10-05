class AddFlagsForInterviewsEtc < ActiveRecord::Migration[5.0]
  def change
    add_column :programs, :has_interviews, :boolean, default: true
    add_column :programs, :has_projects, :boolean, default: true
    add_column :programs, :has_code_reviews, :boolean, default: true
  end
end
