class AddCurrentAssistanceAverageDataToUsers < ActiveRecord::Migration[5.0]
  def up
    Student.find_each(batch_size: 100) do |s|
      s.cohort_assistance_average = s.assistances.completed.where(cohort_id: s.cohort_id).where.not(rating: nil).average(:rating).to_f.round(2)
      s.save!
      puts "updated #{s.first_name} id: #{s.id}"
    end
  end
  def down
    Student.update_all(cohort_assistance_average: nil)
  end
end
