class FetchRemoteActivityContent
  include Interactor

  def call
    activity = context.activity
    file_path = activity.content_file_path
    repo_name = activity.content_repository.full_name

    if file_path
      content = github_client.contents(repo_name, path: file_path, accept: 'application/vnd.github.V3.raw')
      attrs = extract_attributes(content)
      if attrs["outcomes"]
        attrs["outcomes"] = attrs["outcomes"].map {|uuid|
          o = Outcome.find_by_uuid(uuid)
          if not o
            puts "could not find outcome #{uuid}"
          end
          o
        }
      end
      activity.update(attrs)
    end

  rescue Octokit::NotFound => e
    puts "!! FAILED TO FETCH '#{file_path}' FROM GITHUB !!"
    context.fail! error: e.message
  end

  private

  # returns an array containing:
  def extract_attributes(content)
    attrs = extract_frontmatter_attributes(content)
    attrs[:instructions] = content.lstrip.sub(/^---(.*?)---/m, "")
    attrs
  end

  def extract_frontmatter_attributes(content)
    attrs = {}
    if matches = content.lstrip.match(/^---(.*?)---.*/m)
      attrs = YAML.load(matches[1])
    end
    attrs
  end

  def github_client
    return @client if @client
    @client = Octokit::Client.new(access_token: ENV['GITHUB_ADMIN_OAUTH_TOKEN'])
    @client.login
    @client
  end

end
