class User < ActiveRecord::Base
  devise :invitable, :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

 	validates :email, presence: true, uniqueness: true, on: :create
 	
 	has_many :charges
  has_many :stop_orders, through: :charges

  has_many :linked_accounts
  has_many :financial_institutions, through: :linked_accounts

  has_many :charge_wizards
  accepts_nested_attributes_for :charge_wizards

 	has_many :notes, as: :noteable
 	has_one :account_detail

 	default_scope { includes(:account_detail) }

  def name
    id.to_s + ": " + (first_and_last_name.present? ? first_and_last_name : email)
  end

  def first_and_last_name
    if account_detail.present? && account_detail.first_name.present? && account_detail.last_name.present?
      "#{account_detail.first_name} #{account_detail.last_name}"
    else
      nil
    end
  end

  def first_name
    account_detail.present? ? account_detail.first_name : nil
  end

  def phone_verified?
  	account_detail.present? && account_detail.phone_verified.present?
  end

  def phone
    account_detail.formatted_phone
  end

  def linked_account_at?(institution_id)
    linked_accounts.where(financial_institution_id: institution_id).limit(1).first
  end
end