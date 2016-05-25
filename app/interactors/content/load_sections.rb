class Content::LoadSections
  include Interactor

  before do
    @log      = context.log
    @repo_dir = context.repo_dir
    @records  = context.records # we append to this array

    @log.info "LOADING/BUILDING SECTION RECORDS"
  end

  def call
    sections = YAML.load_file(File.join(@repo_dir, 'sections.yml'))['modules']

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
      type:  attributes['type'],
      name:  attributes['name'],
      slug:  attributes['slug'],
      order: attributes['order']
    }

    section = Section.find_or_initialize_by(uuid: uuid)
    section.assign_attributes(attrs)
    section
  end


end
