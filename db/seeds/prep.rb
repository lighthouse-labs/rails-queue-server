########
# PREP CONTENT SEEDING
# This file uses the yml content in db/seeds/prep folder to
# populate REAL curriculum content for the prep course
#
# It's called via the main db/seeds.rb file when running bin/rake db:seed
# It is non-descrutive and creates/updates Prep and Activity records
# and requires all the records to have a uuid present which it uses to
# populate the db with the content from the yml files
#   - KV
########

puts "Loading prep data"

# for tracking and preventing accidental dupe uuids in the data
#   ie copy/paste mistakes
@activity_uuids = []
@section_uuids = []

@default_activity_attributes = {
  remote_content: true,
  content_repository: ContentRepository.first,
  duration: 15,
  allow_submissions: false,
}

def generate_activities(section, activity_data)
  activities = []

  activity_data.each_with_index do |activity_attributes, i|
    uuid = activity_attributes['uuid']
    abort("\n\n---\nHALT! Activity UUID required") if uuid.blank?
    abort("\n\n---\nHALT! Dupe Acitivty UUID found. Check your data, as this is potentially disasterous!") if @activity_uuids.include?(uuid)

    attrs = @default_activity_attributes.merge(activity_attributes)

    # merge YAML frontmatter from external resource
    external_attrs = ExternalResource.fetch_frontmatter(attrs['content_file_path'])
    attrs = attrs.merge(external_attrs)

    attrs[:start_time] = 900 + (i * 30)
    if outcome_uuids = attrs.delete('outcomes')
      attrs['outcomes'] = outcome_uuids.map {|uuid|
        Outcome.find_by_uuid(uuid)
      }.compact
    end
    if quiz_uuid = attrs.delete('quiz')
      attrs['quiz'] = Quiz.find_by(uuid: quiz_uuid)
    end
    if activity = Activity.find_by(uuid: uuid)
      activity.activity_test.try :destroy
      activity.update! attrs.merge(section: section)
      comma
    else
      activity = section.activities.create!(attrs)
      dot
    end

    @activity_uuids << uuid
  end
  activities # created or found activities are returned
end

puts "Loading prep section data"

dir = Rails.root.join('db/seeds/prep').to_s + '/**/*.yml'

Dir.glob(dir).each_with_index do |file, i|
  section_data = YAML.load_file(file)

  print "Prep section #{file}: "; STDOUT.flush

  activity_data = section_data.delete 'activities'

  uuid = section_data['uuid']
  abort("\n\n---\nHALT! Section UUID required") if uuid.blank?
  abort("\n\n---\nHALT! Dupe Section UUID found. Check your data, as this is potentially disasterous!") if @section_uuids.include?(uuid)

  section_data.merge!(order: i+1)

  if section = Prep.find_by(uuid: section_data['uuid'])
    section.update! section_data
    comma # updated
  else
    section = Prep.create! section_data
    dot # created
  end

  @section_uuids << uuid

  print "\n - Activities: "; STDOUT.flush
  generate_activities(section, activity_data)
  puts "\n--"
end

puts "DONE"

