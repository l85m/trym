class StopOrder < ActiveRecord::Base
  belongs_to :charge
  belongs_to :merchant

  has_many :notes, as: :noteable

  validates_presence_of :charge, :merchant, :status
  validates :status, inclusion: { in: %w(requested working succeeded failed) }
end
