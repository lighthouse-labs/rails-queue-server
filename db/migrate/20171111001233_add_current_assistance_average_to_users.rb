class AddCurrentAssistanceAverageToUsers < ActiveRecord::Migration[5.0]
  def change
    Student.find_each(batch_size: 100) do |s|
      s.assistance_average = StudentStats.new(s).bootcamp_assistance_stats[:average_score]
      s.save!
    end
  end
end
