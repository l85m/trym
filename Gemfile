source 'https://rubygems.org'
ruby '2.1.5'
#ruby-gemset=stopcharge

#infra!
gem 'rails', '4.1.7'
gem 'pg'
gem 'bcrypt-ruby', '3.1.2'
gem 'phony_rails'
gem 'sidekiq'
gem 'sinatra', require: false
gem 'slim'
gem 'active_model_serializers'
gem 'wicked' #form wizard
gem 'kaminari' #pagination

#algos
gem 'descriptive_statistics'
gem 'fuzzily', github: 'demosophy/fuzzily', ref: "54739cf6e8ce7fc9528f2d4ac3d204279cfde2b5" #use fork commit for scoped searches (see: https://github.com/mezis/fuzzily/issues/37)
gem 'similar_text'

#apis
gem 'plaid', github: 'demosophy/plaid-ruby', branch: "release_v_1.0"
gem 'twilio-ruby'

#langauge abstraction
gem 'sass-rails'
gem 'haml-rails'
gem 'simple_form'
gem 'autoprefixer-rails'

#ohhh pretty
gem 'bootstrap-sass'
gem 'jquery-ui-rails'
gem "font-awesome-rails"
gem 'premailer-rails'
gem 'nokogiri' #for premailer

#javascript
gem 'coffee-rails', '4.0.1'
gem 'jquery-rails'
gem 'jbuilder', '~> 2.0'
gem 'uglifier', '>= 1.3.0'
gem 'json'
gem 'select2-rails', github: 'demosophy/select2.trym'
gem 'turbolinks'

#users
gem 'devise', github: 'demosophy/devise-3.4.1.usub'
gem 'devise_invitable' #alpha invites

#admin
gem 'activeadmin', github: 'activeadmin'

group :production, :staging do
  gem 'unicorn'
  gem 'mina'
  gem 'mina-sidekiq', require: false
  gem 'mina-unicorn', require: false
  gem 'whenever', require: false
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