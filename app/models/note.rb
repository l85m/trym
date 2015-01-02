class Note < ActiveRecord::Base
  belongs_to :noteable, polymorphic: true
  belongs_to :user

  validates_presence_of :noteable_id, :body, :user_id
end
