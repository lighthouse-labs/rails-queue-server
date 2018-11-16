web: bundle exec puma -e ${RAILS_ENV:-development} -C config/puma.rb
sidekiq: bundle exec sidekiq -q default -q mailers -q scheduled
