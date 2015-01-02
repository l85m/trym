class CallWindow < ActiveRecord::Base
  CALLS_PER_OPERATOR = 4

  has_many :notes, as: :noteable
  has_many :stop_orders, counter_cache: true

  validates_presence_of :window_start, :operators
  validates :operators, numericality: { only_integer: true, greater_than: 0 }
  validates_uniqueness_of :window_start

  scope :windows_for_next_days, -> (days = 2){ where(window_start: (Time.now + 1.day).beginning_of_day..(Time.now + days.day).end_of_day) }
  scope :available_windows, -> { where("(operators * #{CALLS_PER_OPERATOR}) > stop_orders_count") }
  scope :available_windows_for_next_days, -> (days = 2){ windows_for_next_days(days).available_windows.group_by{ |t| t.window_start.localtime.to_date } }
end