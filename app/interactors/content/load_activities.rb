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
            response = Content::ParseActivityFile.call(
              program:       @program,
              repo_dir_path: root_path,
              data_dir_path: "#{data_dir}/_Archived",
              filename:      archived_content_file
            )
            activity_data.push response.attrs
          end
        end

        # no other non .md files allowed (only the `_Archived` folder)
        next unless content_file.ends_with?('.md')
        @current_filename = content_file
        seq_output = sequence_from_file_name ? nil : seq
        response = Content::ParseActivityFile.call(
          program:       @program,
          repo_dir_path: root_path,
          data_dir_path: data_dir,
          filename:      content_file,
          sequence:      seq_output
        )
        activity_data.push response.attrs
        seq += 1
      end
    end

    activity_data
  rescue Exception => e
    raise e, e.message + " \n*suspect filename: #{@current_filename}*", e.backtrace
  end

  def build_records(items)
    items.each do |data|
      Content::LoadActivity.call(repo: @repo, log: @log, data: data, records: @records)
    end
    nil
  end

end
