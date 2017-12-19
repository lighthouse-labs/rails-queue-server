class AddOpenEvaluationDueDate < ActiveRecord::Migration[5.0]
  def up
    Evaluation.pending.each do |eval|
      eval.due = CurriculumDay.new(eval.project.end_day, eval.student.cohort).date
      eval.save
      puts "updated due date on eval id: #{eval.id}"
    end
  end

  def down
    Evaluation.update_all(due: nil)
    puts 'removed due from all evals'
  end
end
