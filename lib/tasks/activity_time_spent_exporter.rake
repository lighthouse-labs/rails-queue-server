namespace :data do
  namespace :activity_time_spent do
    task export: :environment do
      data = []
      all_activities.each do |activity|
        d = activity_details(activity)
        data.push d
      end
      export_data(data)
    end
  end
end

private

def export_data(data)
  file_path = "temp_files/activity_time_spent_data.yml"
  File.open(file_path, "w") do |file|
    file.write(data.to_yaml)
  end
end

def activity_details(activity)
  {
    uuid:               activity.uuid,
    average_time_spent: activity.average_time_spent
  }
end

def all_activities
  Activity.active
end
