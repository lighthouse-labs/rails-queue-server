class Content::LoadSections

  include Interactor

  before do
    @log      = context.log
    @repo     = context.repo
    @repo_dir = context.repo_dir
    @records  = context.records

    @log.info "LOADING/BUILDING SECTION RECORDS"
  end

  def call
    data_dir = 'Sections'
    dir = File.join(@repo_dir, data_dir)

    sections = YAML.load_file(File.join(dir, 'sections.yml'))['sections']

    Content::ValidateUuids.call(collection: sections)
    sections.each do |section_attributes|
      @records.push build_section(section_attributes)
    end
    nil
  end

  private

  def build_section(attributes)
    uuid = attributes.delete 'uuid'

    attrs = {
      content_repository: @repo,
      name:               attributes['name'],
      slug:               attributes['slug'],
      order:              attributes['order']
    }

    section = StudentSection.find_or_initialize_by(uuid: uuid)
    section.assign_attributes(attrs)
    section
  end

end
