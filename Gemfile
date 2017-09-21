# frozen_string_literal: true
source 'https://rubygems.org'

gemspec

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '5.1.0'

# Use Puma as the app server
gem 'puma', '~> 3.7'

# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

gem 'pio', git: 'https://github.com/trema/pio.git', branch: 'develop'
gem 'phut', git: 'https://github.com/trema/phut.git', branch: 'develop'
gem 'trema', git: 'https://github.com/trema/trema.git', branch: 'develop'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  gem 'aruba'
  gem 'cucumber-rails', require: false
  gem 'cucumber-api-steps', require: false
  gem 'factory_girl'
  gem 'rspec-rails'
  gem 'rspec-expectations'
  gem 'rspec-given'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'rubocop'
end
