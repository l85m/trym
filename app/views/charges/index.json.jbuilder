json.array!(@charges) do |charge|
  json.extract! charge, :id, :description, :user_id, :amount, :start_date, :end_date, :renewal_period_in_weeks, :billing_day, :wizard_complete, :last_date_billed, :merchant_id, :recurring, :billed_to_date, :recurring_score, :transaction_request_id, :linked_account_id, :trym_category_id, :history, :plaid_name
  json.url charge_url(charge, format: :json)
end
