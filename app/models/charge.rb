class Charge < ActiveRecord::Base
  belongs_to :user
  belongs_to :merchant
  belongs_to :linked_account
  belongs_to :transaction_request
  belongs_to :plaid_category, foreign_key: :category_id, primary_key: :plaid_id
  belongs_to :trym_category

  has_one :financial_institution, through: :linked_account
  has_many :stop_orders
  
  has_many :notes, as: :noteable

  validates_presence_of :user_id
  validates_numericality_of :amount, only_integer: true, greater_than_or_equal_to: 0, allow_nil: true

  scope :with_merchant, -> { includes(:merchant) }
  scope :with_stop_orders, -> { includes(:stop_orders) }
  scope :with_financial_institution, -> { includes(:financial_institution) }
  scope :fully_loaded, -> {with_merchant.with_stop_orders.with_financial_institution}
  
  scope :recurring_or_likely_to_be_recurring, -> { where(Charge.arel_table[:recurring].eq(true).or(Charge.arel_table[:recurring_score].gt(3))) }
  scope :recurring, -> { where(recurring: true) }
  scope :recurring_likely_to_be, -> {where('recurring_score > ?', 3).where.not(recurring_score: 99)}
  scope :recurring_might_be, -> {where(recurring_score: 2..3)}
  scope :recurring_unlikely_to_be, -> {where(recurring_score: 0..1)}
  scope :recurring_very_unlikely_to_be, -> {where('recurring_score < ?', 0)}

  scope :new_transaction, -> {where(new_transaction: true)}
  scope :not_recurring, -> { where(recurring: false) }
  scope :sort_by_recurring_score, -> { order(recurring_score: :desc) }
  scope :sort_by_new_first, -> { order(new_transaction: :desc) }
  scope :from_link, -> { where.not(transaction_request_id: nil) }
  scope :from_user, -> { where(transaction_request_id: nil) }

  scope :chartable, -> { where('renewal_period_in_weeks > ?', 0).where('amount > 0').where.not(billing_day: nil) }

  fuzzily_searchable :plaid_name

  before_validation :add_user_if_linked_account_exists
  before_validation :update_recurring_score_if_recurring_changed

  def self.renewal_period_in_words
    {
      1   => "Weekly - every week",
      2   => "Bi-Weekly - every other week",
      4   => "Monthly - once every month",
      8   => "Bi-Monthly - every other month",
      12  => "Quarterly - once every three months",
      16  => "4-Monthly - once every four months",
      26  => "Bi-Annually - twice a year",
      52  => "Annually - once a year"
    }
  end

  def warnings
    warnings = {}
    warnings["We don't recognize the company name"] = "Make sure to tell trym which company charged you or we may won't be able to help you stop this charge" unless (merchant.present?)
    warnings["There is no charge amount"] = "We can't show you how much you're paying to this company over time" unless (amount.present? && amount > 0)
    warnings["There is no renewal period"] = "We can't show you how much you're paying to this company over time or warn you before future charges" unless ( renewal_period_in_weeks.present? && renewal_period_in_weeks > 0 )
    warnings["There is no next billing date"] = "We can't show you how much you're paying to this company over time or warn you before future charges" unless billing_day.present?
    warnings
  end

  def details_not_required?
    false
  end

  def amount_in_currency
    return "??" unless amount.present?
    amount.to_f / 100.0
  end

  def recurring_score_grouping
    case recurring_score
    when -100..-1 then "very unlikely to be"
    when 0..1 then "unlikely to be"
    when 2..3 then "might be"
    when 99 then "confirmed by you as"
    else
      "likely to be" 
    end
  end

  def smart_trym_category
    if trym_category.present?
      trym_category
    elsif merchant.present? && merchant.trym_category.present?
      merchant.trym_category
    elsif plaid_category.present? && plaid_category.trym_category.present?
      plaid_category.trym_category
    else
      nil
    end
  end

  def smart_description
    if description.present?
      description
    elsif smart_trym_category.present?
      smart_trym_category.name
    elsif plaid_name.present?
      return plaid_name
    else
      return "(no description)"
    end
  end

  def descriptor
    if merchant.present?
      merchant.name
    else
      smart_description
    end
  end
 
  def merchant_name
    merchant.present? ?  merchant.name : "Unknown"
  end

  def renewal_period_in_words
    Charge.renewal_period_in_words[renewal_period_in_weeks]
  end

  def has_stop_order_or_is_stopped?
    stop_orders.active_or_complete.present?
  end

  def active_stop_order
    stop_orders.active
  end

  def next_billing_date(bill_day = billing_day)
    return nil unless (bill_day.present? && renewal_period_in_weeks.present? && renewal_period_in_weeks > 0 && recurring)
    return bill_day if Date.today <= bill_day
    iterate_billing_date(bill_day)
  end

  def iterate_billing_date(bill_day = billing_day)
    return nil unless (bill_day.present? && renewal_period_in_weeks.present? && renewal_period_in_weeks > 0)
    if renewal_period_in_weeks%4 == 0
      bill_day.to_time.advance(months: bills_since_first_reported_bill * renewal_period_in_months)
                      .advance(months: renewal_period_in_months).to_date
    else
      bill_day.to_time.advance(weeks: bills_since_first_reported_bill * renewal_period_in_weeks)
                      .advance(weeks: renewal_period_in_weeks).to_date
    end
  end

  private

  def add_user_if_linked_account_exists
    if user_id.nil? && linked_account_id.present?
      self.user = linked_account.user
    end
  end

  def update_recurring_score_if_recurring_changed
    if recurring_changed?
      if recurring 
        self.recurring_score = 99
      else
        self.recurring_score = 4
      end
    end
    true
  end

  def bills_since_first_reported_bill
    return 0 if (renewal_period_in_weeks == 0 || billing_day.nil? || Date.today < billing_day)
    ( (Date.today - billing_day) / 7 / renewal_period_in_weeks ).to_i
  end

  def renewal_period_in_months
    renewal_period_in_weeks.to_f / 4.0
  end

end
