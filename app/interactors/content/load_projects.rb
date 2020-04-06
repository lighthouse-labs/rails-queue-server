class Content::LoadProjects

  include Interactor

  before do
    @log      = context.log
    @repo     = context.repo
    @repo_dir = context.repo_dir
    @records  = context.records

    @log.info "LOADING/BUILDING PROJECT RECORDS"
  end

  def call
    project_data = load_all_project_data
    Content::ValidateUuids.call(collection: project_data)
    Content::SetArchive.call(repo_data: project_data, model: Project)
    build_records(project_data)
  end

  private

  def load_all_project_data
    project_data = []

    data_dir = '_Projects'
    dir = File.join(@repo_dir, data_dir)

    seq = 1
    Dir.entries(dir).sort.each do |content_file|
      next if content_file.starts_with?('.')
      # only expect directories for projects (new format)
      full_path = File.join(@repo_dir, data_dir, content_file)
      next unless File.directory?(full_path)
      project_data.push handle_project_directory(@repo_dir, data_dir, content_file, seq)
      seq += 1
    end

    project_data.compact
  end

  def handle_project_directory(repo_dir, data_dir, dir_name, sequence)
    dir_path = File.join(repo_dir, data_dir, dir_name)
    attrs    = YAML.load_file(File.join(dir_path, '_config.yml'))

    attrs['order'] = sequence
    attrs['file_path']     = File.join('data', data_dir, dir_name).to_s
    description_location   = File.join(dir_path, 'description.md')
    teacher_notes_location = File.join(dir_path, 'teacher_notes.md')
    rubric_location        = File.join(dir_path, 'evaluation_rubric.yml')
    guide_location         = File.join(dir_path, 'evaluation_guide.md')
    checklist_location     = File.join(dir_path, 'evaluation_checklist.md')

    attrs['description']          = File.open(description_location).read
    attrs['teacher_notes']        = File.open(teacher_notes_location).read if File.exist?(teacher_notes_location)
    attrs['evaluation_guide']     = File.open(guide_location).read if File.exist?(guide_location)
    if File.exist?(rubric_location)
      attrs['evaluation_rubric']  = YAML.load_file(rubric_location)
      attrs['evaluation_rubric']  = reorder_hash(attrs['evaluation_rubric'])
    end
    attrs['evaluation_checklist'] = File.open(checklist_location).read if File.exist?(checklist_location)
    attrs
  end

  def build_records(items)
    items.each do |data|
      @records.push build_project(data)
    end
    nil
  end

  def reorder_hash(hash)
    ordered = []
    hash.each do |k, data|
      ordered[data['order'].to_i] = [k, data]
    end
    ordered.compact.to_h
  end

  def build_project(attributes)
    uuid = attributes.delete 'uuid'

    attrs = {
      name:                      attributes['name'],
      slug:                      attributes['slug'],
      workbook:                  workbook(attributes['workbook']),
      order:                     attributes['order'],
      start_day:                 attributes['start_day'],
      end_day:                   attributes['end_day'],
      image:                     attributes['image'],
      blurb:                     attributes['blurb'],
      evaluated:                 attributes['evaluated'],
      description:               attributes['description'],
      teacher_notes:             attributes['teacher_notes'],
      content_file_path:         attributes['file_path'],
      evaluation_guide:          attributes['evaluation_guide'],
      evaluation_rubric:         attributes['evaluation_rubric'],
      evaluation_checklist:      attributes['evaluation_checklist'],
      archived:                  attributes['archived'],
      stretch:                   attributes['stretch'],
      background_image_url:      attributes['bg_image_url'],
      background_image_darkness: attributes['bg_image_darkness'],
      content_repository:        @repo
    }

    section = Project.find_or_initialize_by(uuid: uuid)
    section.assign_attributes(attrs)
    section
  end

  def workbook(uuid)
    uuid &&
      (scan_for_record_by_uuid(uuid) || Workbook.find_by(uuid: uuid))
  end

  def scan_for_record_by_uuid(uuid)
    @records.detect { |r| r.uuid == uuid }
  end

end
