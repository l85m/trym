class Charge < ActiveRecord::Base
  belongs_to :user
  belongs_to :merchant
  has_many :notes, as: :noteable

  validates_presence_of :amount, :user_id, :renewal_period_in_weeks, :last_date_billed
  validates :amount, numericality: { only_integer: true, greater_than: 0 }

  scope :with_merchant, -> { joins(:merchant) }

  def self.renewal_period_in_words
    Hash.new("other").merge({
      0   => "other",
      2   => "bi-weekly - two times a month",
      4   => "monthly - once every month",
      8   => "bi-monthly - every other month",
      12  => "quarterly - once every three months",
      16  => "4-monthly - once every four months",
      26  => "bi-annually - twice a year",
      52  => "annually - once a year"
    })
  end

  def details_not_required?
    false
  end

  def create_or_update_from_params(p)
    p = p.collect{ |k,v| [k.to_sym,v] }.to_h
    p[:last_date_billed] = Date.parse(p[:last_date_billed])
    p[:amount] = (p[:amount].to_f * 100).round
    p[:merchant_id] = Merchant.find_or_create_by_name_or_website(p[:merchant_name], p[:merchant_website]).id
    p[:renewal_period_in_weeks] = p[:renewal_period_in_words] == "0" ? p[:renewal_period_in_weeks].to_i : p[:renewal_period_in_words].to_i
    update_attributes p.select{ |k,v| has_attribute?(k) }.to_h
    save! ? self : nil
  end

  def amount_in_currency
    amount.to_f / 100.0
  end
 
  def merchant_name
    merchant.present? ?  merchant.name : nil
  end

  def merchant_website
    merchant.present? ?  merchant.website : nil
  end

  def renewal_period_in_words
    Charge.renewal_period_in_words[renewal_period_in_weeks]
  end

  def next_billing_date(bill_day = last_date_billed)
    if renewal_period_in_weeks%4 == 0
      bill_day.to_time.advance(months: bills_since_first_reported_bill * renewal_period_in_months)
                      .advance(months: renewal_period_in_months).to_date
    else
      bill_day.to_time.advance(weeks: bills_since_first_reported_bill * renewal_period_in_weeks)
                      .advance(weeks: renewal_period_in_weeks).to_date
    end
  end

  private

  def bills_since_first_reported_bill
    ( (Date.today - last_date_billed) / 7 / renewal_period_in_weeks ).to_i
  end

  def renewal_period_in_months
    renewal_period_in_weeks.to_f / 4.0
  end

end
