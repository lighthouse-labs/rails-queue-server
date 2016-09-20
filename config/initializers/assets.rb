Rails.application.config.assets.precompile += %w( admin.js admin.css */*.eot */*.woff */*.ttf */*.svg )

# To resolve issue causing 500 on queue page due to rails5 upgrade and react-rails have issues:
# https://github.com/reactjs/react-rails/issues/443#issuecomment-180544359
Rails.application.config.assets.precompile += %w( react-server.js components.js )