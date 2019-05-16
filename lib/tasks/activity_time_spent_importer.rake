namespace :data do
  namespace :activity_time_spent do
    task import: :environment do
      process_activity_file("temp_files/activity_time_spent_data.yml")
    end
  end
end

private

def process_activity_file(path)
  activity_data = YAML.load(File.read(path))
  activity_data.each do |data|
    process_activity_data(data)
  end
end

def process_activity_data(data)
  a = Activity.find_by uuid: data[:uuid]
  return unless a

  puts "Found activity, updating"

  a.update_columns average_time_spent: data[:average_time_spent]
end
