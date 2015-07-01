json.array!(@financial_institutions) do |financial_institution|
  json.extract! financial_institution, :id, :name, :plaid_type, :has_mfa, :mfa, :plaid_id, :connect
  json.url financial_institution_url(financial_institution, format: :json)
end
