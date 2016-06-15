class Content::DownloadRepoArchive
  include Interactor

  before do
    @log  = context.log
    @repo = context.repo
    @sha  = context.sha

    @log.info "FETCHING (#{@repo.full_name})"
  end

  def call
    require 'open-uri'

    determine_sha unless @sha
    @log.info "SHA: #{@sha}"

    # https://developer.github.com/v3/repos/contents/#get-archive-link
    # https://github.com/octokit/octokit.rb/blob/master/lib/octokit/client/contents.rb#L152
    remote_archive_location = github.archive_link(@repo.full_name, ref: @sha)

    local_dir = Rails.root.join('tmp', "curriculum", "#{Time.now.to_i}")
    tarball_path = local_dir.join('archive.tar.gz')
    content_path = local_dir.join('contents')

    @log.info "Downloading into #{local_dir}"
    FileUtils.mkdir_p local_dir
    File.open(tarball_path, "wb") do |saved_file|
      open(remote_archive_location, "rb") do |read_file|
        saved_file.write(read_file.read)
      end
    end

    @log.info "Extracting #{tarball_path} into #{content_path}"
    File.open(tarball_path) do |f|
      tar = ungzip(f)
      untar(tar, content_path)
    end

    repo_dir = Dir.glob(content_path.join('*')).detect { |f| File.directory? f }

    raise "Error: Expected " unless repo_dir.present?

    # we only care about the contents within
    context.repo_dir = File.join(repo_dir, 'data')
  end

  private

  def determine_sha
    @log.debug 'No sha provided, so finding out from GitHub... '
    context.sha = @sha = github.ref(@repo.full_name, 'heads/master')[:object][:sha]
  end

  # Taken from: https://gist.github.com/sinisterchipmunk/1335041 - KV
  def untar(io, destination)
    Gem::Package::TarReader.new io do |tar|
      tar.each do |tarfile|
        destination_file = File.join destination, tarfile.full_name

        if tarfile.directory?
          FileUtils.mkdir_p destination_file
        else
          destination_directory = File.dirname(destination_file)
          FileUtils.mkdir_p destination_directory unless File.directory?(destination_directory)
          File.open destination_file, "wb" do |f|
            f.print tarfile.read
          end
        end
      end
    end
  end

  # Taken from: https://gist.github.com/sinisterchipmunk/1335041 - KV
  def ungzip(tarfile)
    require 'rubygems/package'
    require 'zlib'
    require 'fileutils'

    z = Zlib::GzipReader.new(tarfile)
    unzipped = StringIO.new(z.read)
    z.close
    unzipped
  end

  def github
    return @client if @client
    @client = Octokit::Client.new(access_token: ENV['GITHUB_ADMIN_OAUTH_TOKEN'])
    @client.login
    @client
  end

end