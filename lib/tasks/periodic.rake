namespace :periodic do
  desc "Looks for linked accounts that are taking too long to sync and sends a notification to the user."
  task delayed_link_notifier: :environment do
    LinkDelayNotifier.new
  end

  task notify_of_sidekiq_failure: :environment do
  	sidekiq_processes = `ps aux | grep sidekiq`
  	unless sidekiq_processes.split("\n").any?{ |p| p.include? "sidekiq 3.3.0 trym" }
  		Twilio::REST::Client.new.account.messages.create(
				from: Rails.application.secrets.twilio_from_number,
				to: "206-235-8245",
				body: "#{Time.now.getlocal('-07:00')}\nSERVER SAYS: Sidekiq May Be Down\n#{sidekiq_processes}"
			)
  	end
  end
end