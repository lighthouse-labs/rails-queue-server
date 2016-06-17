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
      next unless content_file.ends_with?('.md')
      project_data.push extract_project_file_data(@repo_dir, data_dir, content_file, seq)
      seq += 1
    end

    project_data
  end

  def extract_project_file_data(repo_dir, data_dir, filename, sequence)
    content = File.open(File.join(repo_dir, data_dir, filename)).read
    attrs = extract_attributes(content)
    filename_parts = filename.split('__')
    attrs['file_path'] = File.join('data', data_dir, filename).to_s
    attrs['name'] ||= URI.unescape(filename_parts[-2].strip)
    attrs['order'] = sequence
    attrs
  end

  # returns an array containing:
  def extract_attributes(content)
    attrs = extract_frontmatter_attributes(content)
    attrs['markdown'] = content.lstrip.sub(/^---(.*?)---/m, "")
    attrs
  end

  def extract_frontmatter_attributes(content)
    attrs = {}
    if matches = content.lstrip.match(/^---(.*?)---.*/m)
      attrs = YAML.load(matches[1])
    end
    attrs
  end

  def build_records(items)
    items.each do |data|
      @records.push build_project(data)
    end
    nil
  end

  def build_project(attributes)
    uuid = attributes.delete 'uuid'

    attrs = {
      name:      attributes['name'],
      slug:      attributes['slug'],
      order:     attributes['order'],
      start_day: attributes['start_day'],
      end_day:   attributes['end_day'],
      image:     attributes['image'],
      blurb:     attributes['blurb'],
      description: attributes['markdown'],
      content_file_path: attributes['file_path'],
      content_repository: @repo,
    }

    section = Project.find_or_initialize_by(uuid: uuid)
    section.assign_attributes(attrs)
    section
  end

end