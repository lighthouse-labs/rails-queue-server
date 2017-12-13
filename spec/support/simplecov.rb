if ENV['COV'] == '1'
  puts 'Running with coverage on (COV=1)! ...'
  # https://github.com/colszowka/simplecov#getting-started
  require 'simplecov'

  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new(
    [
      SimpleCov::Formatter::HTMLFormatter
    ]
  )

  SimpleCov.start :rails do
    add_group "Interactors", "app/interactors"
    add_filter '.gems'
    add_filter 'pkg'
    add_filter 'spec'
    add_filter 'vendor'
  end
end
