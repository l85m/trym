class Charge < ActiveRecord::Base
  belongs_to :user
  belongs_to :merchant
  belongs_to :linked_account
  belongs_to :transaction_request
  belongs_to :plaid_category, foreign_key: :category_id, primary_key: :plaid_id
  belongs_to :trym_category

  has_one :financial_institution, through: :linked_account
  has_many :stop_orders, dependent: :destroy
  has_many :notes, as: :noteable
  has_many :transactions

  validates_presence_of :user_id
  validates_numericality_of :amount, only_integer: true, greater_than_or_equal_to: 0, allow_nil: true

  scope :with_merchant, -> { includes(:merchant) }
  scope :with_stop_orders, -> { includes(:stop_orders) }
  scope :with_active_stop_orders, -> {joins(:stop_orders).where('stop_orders.status' => ['requested', 'working'])}
  scope :with_financial_institution, -> { includes(:financial_institution) }
  scope :with_trym_category, -> { includes(:trym_category) }

  scope :recurring_or_likely_to_be_recurring, -> { where(Charge.arel_table[:recurring].eq(true).or(Charge.arel_table[:recurring_score].gt(3))) }
  scope :recurring, -> { where(recurring: true) }
  scope :not_recurring, -> { where(recurring: [false,nil]) }
  scope :recurring_likely_to_be, -> {not_recurring.where('recurring_score > ?', 3)}
  scope :recurring_might_be, -> {not_recurring.where(recurring_score: 2..3)}
  scope :recurring_unlikely_to_be, -> {not_recurring.where(recurring_score: 0..1)}
  scope :recurring_very_unlikely_to_be, -> {not_recurring.where('recurring_score < ?', 0)}

  scope :uncategorized, -> { where(id: all.reject{ |x| x.smart_trym_category.present? }.collect(&:id) ) }
  scope :sort_by_recurring_score, -> { order("recurring desc NULLS LAST, recurring_score desc NULLS LAST, id desc") }
  scope :from_link, -> { where.not(transaction_request_id: nil) }
  scope :from_user, -> { where(transaction_request_id: nil) }

  scope :has_recurring_period, -> { where('renewal_period_in_weeks > ?', 0).where.not( renewal_period_in_weeks: nil ) }
  scope :has_billing_day, -> { where.not(billing_day: nil) }

  scope :chartable, -> { has_recurring_period.has_billing_day.where('amount > 0') }
  scope :complete, -> { chartable.where.not(merchant_id: nil).where.not(history: nil) }

  fuzzily_searchable :plaid_name

  before_validation :add_user_if_linked_account_exists
  before_validation :add_trym_category_if_merchant_has_one
  # before_validation :update_recurring_score_if_recurring_changed

  def self.due_in_three_days
    recurring.has_billing_day.has_recurring_period.select do |charge|      
      charge.next_billing_date == 3.days.from_now.to_date
    end
  end

  def self.charged_in_month
    recurring.has_billing_day.has_recurring_period.select do |charge|      
      charge.amount_charged_last_month > 0
    end
  end


  def self.new_transaction(new_after = 30.days.ago.to_date)
    where("history ?| :date", date: "{#{(new_after..Date.today).to_a.map(&:to_s).join(",")}}")
  end

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

  def self.rescore
    where.not(history: nil).each do |charge|
      charge.update( recurring_score: TransactionScorer.new(charge).score )
    end
  end

  def history
    transactions.order(date: :desc).pluck(:date, :amount).map{ |date,amount| [date, amount/100.0] }.to_h
  end

  def rescore!
    update( recurring_score: TransactionScorer.new(self).score )
  end

  def history_with_long_dates
    history.collect{ |date,value| [date.strftime("%b %e, %Y"),value] }.to_h
  end

  def new_transaction(new_after = 30.days.ago)
    if history.present?
      history.keys.max >= new_after
    end
  end

  def reason_for_score
    if transaction_request.present?
      TransactionScorer.new(self, transaction_request).reason_for_score
    else
      nil
    end
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
    return nil unless amount.present?
    amount.to_f / 100.0
  end

  def amount_charged_last_month
    case renewal_period_in_weeks
    when 4 then 1
    when 2 then 2
    when 1 then 4
    else
      bills_since(1.month.ago.beginning_of_month.to_date)
    end * amount
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

  def smart_category_name
    if plaid_category.present?
      plaid_category.hierarchy.last
    elsif trym_category.present?
      trym_category.name
    elsif merchant.present? && merchant.trym_category.present?
      merchant.trym_category.name
    else
      nil
    end
  end

  def smart_trym_category
    if trym_category.present?
      trym_category.name
    elsif plaid_category.present? && plaid_category.trym_category.present?
      plaid_category.trym_category.name
    elsif merchant.present? && merchant.trym_category.present?
      merchant.trym_category.name
    else
      nil
    end
  end

  def smart_description
    if plaid_name.present?
      plaid_name
    elsif smart_trym_category.present?
      smart_category_name
    else
      nil
    end
  end

  def descriptor
    if merchant.present?
      merchant.name
    elsif plaid_name.present?
      plaid_name
    else
      "Unknown Merchant"
    end
  end
 
  def merchant_name
    merchant.present? ?  merchant.name : "Unknown"
  end

  def renewal_period_in_words
    Charge.renewal_period_in_words[renewal_period_in_weeks]
  end

  def has_active_stop_order?
    stop_orders.where(status: ["working", "requested"]).present?
  end

  def active_stop_order
    stop_orders.active
  end

  def last_billed_date
    return nil unless billing_day.present?
    return billing_day if billing_day < Time.now
    billing_day - ( renewal_period_in_weeks * 7 )
  end

  def next_billing_date(bill_day = billing_day)
    return nil unless (bill_day.present? && renewal_period_in_weeks.present? && renewal_period_in_weeks > 0 && recurring)
    return bill_day if Date.today <= bill_day
    iterate_billing_date(bill_day)
  end

  def iterate_billing_date(bill_day = billing_day)
    return nil unless (bill_day.present? && renewal_period_in_weeks.present? && renewal_period_in_weeks > 0)
    if renewal_period_in_weeks%4 == 0
      bill_day.to_time.advance(months: bills_since(bill_day) * renewal_period_in_months)
                      .advance(months: renewal_period_in_months).to_date
    else
      bill_day.to_time.advance(weeks: bills_since(bill_day) * renewal_period_in_weeks)
                      .advance(weeks: renewal_period_in_weeks).to_date
    end
  end

  private

  def add_trym_category_if_merchant_has_one
    if merchant.present? && merchant.trym_category_id.present?
      self.trym_category_id = merchant.trym_category_id
    end
  end

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

  def bills_since(bill_day)
    return 0 if (renewal_period_in_weeks == 0 || bill_day.nil? || Date.today < bill_day)
    if renewal_period_in_weeks % 4 == 0
      ( ( (Date.today - bill_day) / 30.43683 ).to_i / renewal_period_in_months ).floor
    else
      ( ( (Date.today - bill_day) / 7.0 ).to_i / renewal_period_in_weeks ).floor
    end
  end

  def renewal_period_in_months
    renewal_period_in_weeks.to_f / 4.0
  end

end
