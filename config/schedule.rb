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

every 6.hours do
  runner "PlaidFinancialInstitutionUpdater.perform_async"
  runner "PlaidCategoryUpdater.perform_async"
end

every 1.hours do
	runner "PlaidLinkedAccountUpdater.new"
end

every 1.minute do
	echo 'test'
end


# Learn more: http://github.com/javan/whenever
