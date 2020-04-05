# Instead of having these in the .env, due to the multi line private key which causes a bug in dokku that prevents deployment, we've put these secrets into the Programs table. Perhaps they are better there anyway? - KV

# Fails on first run if you dont have the migration run yet, hence using .try
begin
  creds = Program.first.try(:settings) if ActiveRecord::Base.connection.table_exists? 'programs'
  creds ||= {}
  google_creds = creds['google_app_credentials'] || {}
  ENV['GOOGLE_ACCOUNT_TYPE'] ||= google_creds['GOOGLE_ACCOUNT_TYPE']
  ENV['GOOGLE_PRIVATE_KEY_ID'] ||= google_creds['GOOGLE_PRIVATE_KEY_ID']
  ENV['GOOGLE_PRIVATE_KEY'] ||= google_creds['GOOGLE_PRIVATE_KEY']
  ENV['GOOGLE_CLIENT_EMAIL'] ||= google_creds['GOOGLE_CLIENT_EMAIL']
  ENV['GOOGLE_CLIENT_ID'] ||= google_creds['GOOGLE_CLIENT_ID']
  ENV['GOOGLE_SUB_EMAIL'] ||= google_creds['GOOGLE_SUB_EMAIL']
rescue err =>
  puts "Could not initialize google app credentials"
end