json.array!(@plaid_categories) do |plaid_category|
  json.extract! plaid_category, :id, :plaid_type, :hierarchy, :plaid_id, :trym_category_id
  json.url plaid_category_url(plaid_category, format: :json)
end
