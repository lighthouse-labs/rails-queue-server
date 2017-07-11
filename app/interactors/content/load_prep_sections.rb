class Content::LoadPrepSections

  include Interactor

  before do
    @repo     = context.repo
    @log      = context.log
    @repo_dir = context.repo_dir
    @records  = context.records # we append to this array

    @log.info "LOADING/BUILDING PREP SECTION RECORDS"
  end

  def call
    sections = YAML.load_file(File.join(@repo_dir, 'prep.yml'))['sections']

    Content::ValidateUuids.call(collection: sections)
    sections.each do |section_attributes|
      @records.push build_prep_section(section_attributes)
    end

    nil
  end

  private

  def build_prep_section(attributes)
    uuid = attributes.delete 'uuid'

    attrs = {
      content_repository: @repo,
      name:               attributes['name'],
      slug:               attributes['slug'],
      order:              attributes['order']
    }

    section = Prep.find_or_initialize_by(uuid: uuid)
    section.assign_attributes(attrs)
    section
  end

end
