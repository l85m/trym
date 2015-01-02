require 'capybara/poltergeist'

Capybara.register_driver :my_firefox_driver do |app|
  profile = Selenium::WebDriver::Firefox::Profile.new    
  Capybara::Selenium::Driver.new(app, :browser => :firefox, :profile => profile)
end