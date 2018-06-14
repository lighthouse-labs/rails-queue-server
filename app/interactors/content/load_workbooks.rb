class Content::LoadWorkbooks

  include Interactor

  before do
    @log      = context.log
    @repo     = context.repo
    @repo_dir = context.repo_dir
    @records  = context.records

    @log.info "LOADING/BUILDING WORKBOOK RECORDS"
  end

  def call
    workbook_data = load_all_workbook_data
    Content::ValidateUuids.call(collection: workbook_data)
    Content::SetArchive.call(repo_data: workbook_data, model: Workbook)
    build_records(workbook_data)
  end

  private

  def load_all_workbook_data
    workbook_data = []

    data_dir = '_Workbooks'
    dir = File.join(@repo_dir, data_dir)

    # _Workbooks is an optional directory that we don't expect to exist in all content repos
    return [] unless File.exist? dir

    Dir.entries(dir).sort.each do |content_file|
      next if content_file.starts_with?('.')
      # only expect directories for workbooks (new format)
      full_path = File.join(@repo_dir, data_dir, content_file)
      next unless File.directory?(full_path)
      workbook_data.push handle_workbook_directory(@repo_dir, data_dir, content_file)
    end

    workbook_data.compact
  end

  def handle_workbook_directory(repo_dir, data_dir, dir_name)
    dir_path = File.join(repo_dir, data_dir, dir_name)
    attrs    = YAML.load_file(File.join(dir_path, '_config.yml'))
    desc_file = File.join(dir_path, 'description.md')
    attrs['description'] = File.open(desc_file).read if File.exist?(desc_file)

    attrs['file_path'] = File.join('data', data_dir, dir_name).to_s
    attrs
  end

  def build_records(items)
    items.each do |data|
      modules  = data['modules']
      workbook = build_workbook(data)
      @records.push workbook

      modules.each do |module_attributes|
        Content::LoadWorkModule.call(
          repo:     @repo,
          log:      @log,
          repo_dir: @repo_dir,
          records:  @records,
          workbook: workbook,
          data:     module_attributes
        )
      end
    end
    nil
  end

  def build_workbook(attributes)
    uuid = attributes.delete 'uuid'

    attrs = {
      name:               attributes['name'],
      slug:               attributes['slug'],
      unlock_on_day:      attributes['unlock_on_day'],
      public:             attributes['public'],
      archived:           attributes['archived'],
      description:        attributes['description'],
      content_file_path:  attributes['file_path'],
      content_repository: @repo
    }

    workbook = Workbook.find_or_initialize_by(uuid: uuid)
    workbook.assign_attributes(attrs)
    workbook
  end

end
