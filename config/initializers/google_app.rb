# Instead of having these in the .env, due to the multi line private key which causes a bug in dokku that prevents deployment, we've put these secrets into the Programs table. Perhaps they are better there anyway? - KV

# Fails on first run if you dont have the migration run yet, hence using .try
creds = Program.first.try(:google_app_credentials) || {}
ENV['GOOGLE_ACCOUNT_TYPE'] ||= creds['GOOGLE_ACCOUNT_TYPE']
ENV['GOOGLE_PRIVATE_KEY_ID'] ||= creds['GOOGLE_PRIVATE_KEY_ID']
ENV['GOOGLE_PRIVATE_KEY'] ||= creds['GOOGLE_PRIVATE_KEY']
ENV['GOOGLE_CLIENT_EMAIL'] ||= creds['GOOGLE_CLIENT_EMAIL']
ENV['GOOGLE_CLIENT_ID'] ||= creds['GOOGLE_CLIENT_ID']
ENV['GOOGLE_SUB_EMAIL'] ||= creds['GOOGLE_SUB_EMAIL']
