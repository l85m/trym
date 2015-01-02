source 'https://rubygems.org'
ruby '2.1.5'
#ruby-gemset=stopcharge

#infra!
gem 'rails', '4.1.7'
gem 'turbolinks'
gem 'pg'
gem 'bcrypt-ruby', '3.1.2'
gem 'mechanize'
gem 'twilio-ruby'
gem 'phony_rails'

#account linking gems
gem 'similar_text'
gem 'capybara', '2.1.0'

#langauge abstraction
gem 'sass-rails'
gem 'haml-rails'
gem 'simple_form'
gem 'autoprefixer-rails'

#ohhh pretty
gem 'bootstrap-sass'
gem 'jquery-ui-rails'

#javascript
gem 'coffee-rails', '4.0.1'
gem 'jquery-rails'
gem 'jbuilder', '~> 2.0'
gem 'uglifier', '>= 1.3.0'
gem 'json'
gem 'ember-rails'

#users
gem 'devise', github: 'demosophy/devise-3.4.1.usub'

group :production, :staging do
  gem 'unicorn'
  gem 'mina'
  gem 'mina-sidekiq', :require => false
  gem 'mina-unicorn', :require => false
end

group :development, :test do
  gem 'rspec-rails', '2.13.1'
  gem 'spork-rails', '4.0.0'
  gem 'childprocess'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'meta_request'
  gem 'pry-rails'
  gem 'quiet_assets'
  gem 'ffaker'
end

group :test do
  gem 'selenium-webdriver', '2.43'
  gem 'rspec-nc'
  gem 'factory_girl_rails'
end

group :doc do
	gem 'sdoc', '~> 0.4.0'
end