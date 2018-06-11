class Content::ParseActivityFile

  include Interactor

  before do
    @log      = context.log
    @repo     = context.repo
    @program  = context.program

    @repo_dir_path = context.repo_dir_path
    @data_dir_path = context.data_dir_path
    @filename = context.filename
    @dayless  = context.dayless  # for workbook activities, there is no day set
    @sequence = context.sequence # also optional
  end

  def call
    content = File.open(File.join(@repo_dir_path, @data_dir_path, @filename)).read
    attrs = extract_attributes(content)
    day_from_file = attrs['day']
    filename_parts = @filename.split('__')

    attrs['sequence'] = @sequence ? @sequence : filename_parts.first.to_i
    attrs['file_path'] = File.join('data', @data_dir_path, @filename).to_s
    attrs['type'] = filename_parts.last.split('.').first.strip
    attrs['day'] = determine_day(day_from_file, @data_dir_path) unless @dayless
    # We use the relevant part of the md file name if name attribute is not set in yaml front matter
    attrs['name'] ||= URI.unescape(filename_parts[-2].strip)

    context.attrs = attrs
  end

  private

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

  def determine_day(day_from_file, data_dir)
    curric_day = day_from_file || day_from_folder_name(data_dir) # eg: w1d3 or w4e
    return nil if curric_day.nil? || curric_day.match(DAY_REGEX).nil?
    activity_week = /\d+/.match(curric_day).to_s.to_i
    curric_day.insert(1, "0") if @program.weeks > 9 && activity_week < 10
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

end
