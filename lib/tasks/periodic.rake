namespace :periodic do
  desc "Looks for linked accounts that are taking too long to sync and sends a notification to the user."
  task delayed_link_notifier: :environment do
    LinkDelayNotifier.perform_async
  end

end
