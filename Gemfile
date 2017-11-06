source 'https://rubygems.org'
ruby '2.4.0'

#use unicorn server
platforms :ruby do # linux
   gem 'unicorn'
end

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails'

# Use sqlite3 as the database for Active Record
group :development do
  gem 'sqlite3'
end

#for heroku
group :production do
  gem 'pg'
end

# Use SCSS for stylesheets
gem 'sass-rails'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer',  platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', group: :doc

# gems required for ADIwg mdTranslator ...
# Use json as JSON
gem 'json'
# Use build as XML constructor
gem 'builder'
# Use thor to handle command line interface to metadata translator
gem 'thor'
# Use uuidtools to create unique identifiers
gem 'uuidtools'
# Use json_schema as schema validator
gem 'json-schema'
# Alaska Data Integration working group schema definition
gem 'adiwg-mdjson_schemas', '~> 2.3.2'
# Alaska Data Integration working group metadata translator
gem 'adiwg-mdtranslator', '~> 2.5.0'
# Alaska Data Integration working group metadata code lists
gem 'adiwg-mdcodes', '~> 2.3.2'

# Use kramdown to render markdown with help of coderay
gem 'kramdown'
gem 'coderay'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
# added x64_mingw for Windows x64 operating systems
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw]
# assets for heroku
gem 'rails_12factor', group: :production
# CORS support
gem 'rack-cors'
# timeout
gem 'rack-timeout'
