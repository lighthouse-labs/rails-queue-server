# https://github.com/zurb/inky-rb#alternative-template-engine
Inky.configure do |config|
  config.template_engine = :slim
end

# For some reason, their docs don't ask for this ?
Rails.application.config.assets.precompile += %w(foundation_emails.css)