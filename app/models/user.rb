class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

 	validates :email, presence: true, uniqueness: true, on: :create
 	
 	has_many :charges
  has_many :linked_accounts
  has_many :financial_institutions, through: :linked_accounts

 	has_many :notes, as: :noteable
 	has_one :account_detail

 	default_scope { includes(:account_detail) }

  def first_and_last_name
    account_detail.present? ? "#{account_detail.first_name} #{account_detail.last_name}" : nil
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
end