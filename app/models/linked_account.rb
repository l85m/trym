class LinkedAccount < ActiveRecord::Base
  belongs_to :user
  belongs_to :financial_institution
end
