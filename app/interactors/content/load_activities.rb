class Content::LoadActivities

  include Interactor

  before do
    @log      = context.log
    @repo     = context.repo
    @repo_dir = context.repo_dir
    @records  = context.records
    @program  = Program.first

    @log.info "LOADING/BUILDING ACTIVITY RECORDS"
  end

  def call
    activity_data  = load_all_activity_data
    activity_data += load_all_activity_data('Training') if Dir.exist?(File.join(@repo_dir, 'Training').to_s)
    activity_data += load_all_activity_data('Sections', true) if Dir.exist?(File.join(@repo_dir, 'Sections').to_s)
    activity_data += load_workbook_activities if Dir.exist?(File.join(@repo_dir, '_Workbooks').to_s)
    Content::ValidateUuids.call(collection: activity_data)
    Content::SetArchive.call(repo_data: activity_data, model: Activity)
    build_records(activity_data)
  end

  private

  def load_workbook_activities
    subdir = '_Workbooks'
    root_path = File.join(@repo_dir, subdir)
    data = []

    Dir.entries(root_path).sort.each do |data_dir|
      filepath = File.join(root_path, data_dir)
      next if data_dir.starts_with?('.')
      path = File.join(subdir, data_dir, 'activities').to_s
      data += load_all_activity_data(path, false) if File.directory?(filepath)
    end

    data
  end

  # The sequence_from_file_name is a hack for week5 content
  # For those activities, we want the sequence field to be populated from the file name
  # TBH all the files in the repo should have that to true, but it will cause every activity to change so that would suck
  def load_all_activity_data(subdir = '', sequence_from_file_name = false)
    activity_data = []

    root_path = File.join(@repo_dir, subdir)

    Dir.entries(root_path).sort.each do |data_dir|
      filepath = File.join(root_path, data_dir)
      next if data_dir.starts_with?('.')
      next if data_dir.starts_with?('_')
      next unless File.directory?(filepath)
      seq = 1
      Dir.entries(filepath).sort.each do |content_file|
        next if content_file.starts_with?('.')
        if content_file == '_Archived'
          Dir.entries(File.join(filepath, content_file)).sort.each do |archived_content_file|
            next if archived_content_file.starts_with?('.')
            next unless archived_content_file.ends_with?('.md')
            @current_filename = archived_content_file
            activity_data.push extract_activity_file_data(root_path, "#{data_dir}/_Archived", archived_content_file)
          end
        end

        # no other non .md files allowed (only the `_Archived` folder)
        next unless content_file.ends_with?('.md')
        @current_filename = content_file
        seq_output = sequence_from_file_name ? nil : seq
        activity_data.push extract_activity_file_data(root_path, data_dir, content_file, seq_output)
        seq += 1
      end
    end

    # @log.debug 'ACTIVITY DATA:'
    # @log.debug activity_data.awesome_inspect

    activity_data
  rescue Exception => e
    raise e, e.message + " \n*suspect filename: #{@current_filename}*", e.backtrace
  end

  def extract_activity_file_data(repo_dir, data_dir, filename, sequence = nil)
    content = File.open(File.join(repo_dir, data_dir, filename)).read
    attrs = extract_attributes(content)
    day_from_file = attrs['day']
    filename_parts = filename.split('__')

    attrs['sequence'] = sequence ? sequence : filename_parts.first.to_i
    attrs['file_path'] = File.join('data', data_dir, filename).to_s
    attrs['type'] = filename_parts.last.split('.').first.strip
    attrs['day'] = determine_day(day_from_file, data_dir)
    # We use the relevant part of the md file name if name attribute is not set in yaml front matter
    attrs['name'] ||= URI.unescape(filename_parts[-2].strip)
    attrs
  end

  def determine_day(day_from_file, data_dir)
    curric_day = day_from_file || day_from_folder_name(data_dir) # eg: w1d3 or w4e
    return nil if curric_day.nil? || curric_day.match(DAY_REGEX).nil?
    activity_week = /\d+/.match(curric_day).to_s.to_i
    if @program.weeks > 9 && activity_week < 10
      curric_day.insert(1,"0")
    end
    curric_day
  end

  def day_from_folder_name(dirname)
    # We extract the W1D1 type day format used by Compass from the content file's parent folder (curriculum content naming convention)
    case dirname
    when /Week (\d+) Day (\d)/
      "w#{Regexp.last_match(1)}d#{Regexp.last_match(2)}"
    when /Week (\d+) Weekend/
      "w#{Regexp.last_match(1)}e"
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
      attrs = YAML.safe_load(matches[1])
    end
    attrs
  end

  def build_records(items)
    items.each do |data|
      Content::LoadActivity.call(repo: @repo, log: @log, data: data, records: @records)
    end
    nil
  end

end
