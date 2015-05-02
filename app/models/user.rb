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
  has_many :stop_order_jobs, foreign_key: 'operator_id', class_name: "StopOrder"

  scope :alertable, -> {where("email_alert = ? or text_alert = ?", true, true)}
  scope :text_alertable, -> {where(text_alert: true)}
  scope :email_alertable, -> {where(email_alert: true)}
  
  scope :summarizable, -> {where('email_summary = ? or text_summary = ?', true, true)}
  scope :text_summarizable, -> {where(text_summary: true)}
  scope :email_summarizable, -> {where(email_summary: true)}

  scope :admins, -> {where(admin: true)}

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