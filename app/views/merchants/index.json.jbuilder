json.array!(@merchants) do |merchant|
  json.extract! merchant, :id, :name, :type, :validated, :recurring_score, :trym_category_id, :cancellation_fields
  json.url merchant_url(merchant, format: :json)
end
