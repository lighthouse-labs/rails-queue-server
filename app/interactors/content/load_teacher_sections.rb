class Content::LoadTeacherSections

  include Interactor

  before do
    @log      = context.log
    @repo     = context.repo
    @repo_dir = context.repo_dir
    @records  = context.records

    @log.info "LOADING/BUILDING TEACHER ACTIVITY RECORDS"
  end

  def call
    data_dir = 'Training'
    dir = File.join(@repo_dir, data_dir)

    sections = YAML.load_file(File.join(dir, 'sections.yml'))['sections']

    Content::ValidateUuids.call(collection: sections)
    Content::SetArchive.call(repo_data: sections, model: TeacherSection)
    sections.each do |section_attributes|
      @records.push build_teacher_section(section_attributes)
    end
    nil
  end

  private

  def build_teacher_section(attributes)
    uuid = attributes.delete 'uuid'

    attrs = {
      content_repository: @repo,
      name:               attributes['name'],
      slug:               attributes['slug'],
      order:              attributes['order']
    }

    section = TeacherSection.find_or_initialize_by(uuid: uuid)
    section.assign_attributes(attrs)
    section
  end

end
