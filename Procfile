web: bundle exec puma -e ${RAILS_ENV:-development} -C config/puma.rb
worker: bundle exec sidekiq -q default -q mailers -q scheduled
