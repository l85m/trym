# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#

set :output, "~/trym/shared/log/cron_log.log"

every 1.day, :at => '1:30 am' do
  runner "PlaidFinancialInstitutionUpdater.perform_async"
  runner "PlaidCategoryUpdater.perform_async"
 	runner "AlertWorker.perform_async"
end

every 1.minute do 
	runner "AlertWorker.perform_async"
end

every '30 0 1 * *' do
	runner "SummaryWorker.perform_async"
end

# Learn more: http://github.com/javan/whenever
