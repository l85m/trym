require "capybara"
require "capybara/poltergeist"
require "capybara/poltergeist/utility"

module Capybara::Poltergeist
  Client.class_eval do
    def start
      @pid = Process.spawn(*command.map(&:to_s), pgroup: true)
      ObjectSpace.define_finalizer(self, self.class.process_killer(@pid))
    end
 
    def stop
      if pid
        kill_phantomjs
        ObjectSpace.undefine_finalizer(self)
      end
    end
  end
end

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, js_errors: false, timeout: 10000, phantomjs_options: ['--load-images=no', '--ignore-ssl-errors=yes', '--ssl-protocol=any'], "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.95 Safari/537.36")
end

Capybara.javascript_driver = :poltergeist