class Content::LoadActivities
  include Interactor

  before do
    @log      = context.log
    @repo_dir = context.repo_dir
    @records  = context.records

    @log.info "LOADING/BUILDING ACTIVITY RECORDS"
  end

  def call
    activity_data = load_all_activity_data
    Content::ValidateUuids.call(collection: activity_data)
    build_records(activity_data)
  end

  private

  def load_all_activity_data
    activity_data = []

    Dir.foreach(@repo_dir) do |data_dir|
      filepath = File.join(@repo_dir, data_dir)
      next if data_dir.starts_with?('.')
      next if data_dir.starts_with?('_')
      next unless File.directory?(filepath)
      Dir.foreach(filepath) do |content_file|
        next if content_file.starts_with?('.')
        next unless content_file.ends_with?('.md')
        activity_data.push extract_activity_file_data(@repo_dir, data_dir, content_file)
      end
    end

    # @log.debug 'ACTIVITY DATA:'
    # @log.debug activity_data.awesome_inspect

    activity_data
  end

  def extract_activity_file_data(repo_dir, data_dir, filename)
    content = File.open(File.join(repo_dir, data_dir, filename)).read
    attrs = extract_attributes(content)
    attrs['type'] = filename.split('__').last.split('.').first.strip
    # We extract the W1D1 type day format used by Compass from the content file's parent folder (curriculum content naming convention)
    attrs['day']  = day_from_folder_name(data_dir) # eg: w1d3 or w4e
    # We use the relevant part of the md file name if name attribute is not set in yaml front matter
    attrs['name'] ||= URI.unescape(filename.split('__')[-2].strip)
    attrs
  end

  def day_from_folder_name(dirname)
    case dirname
    when /Week (\d+) Day (\d)/
      "w#{$1}d#{$2}"
    when /Week (\d+) Weekend/
      "w#{$1}e"
    else
      nil
    end
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
      Content::LoadActivity.call(log: @log, data: data, records: @records)
    end
    nil
  end

end