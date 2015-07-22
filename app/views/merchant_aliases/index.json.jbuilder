json.array!(@merchant_aliases) do |merchant_alias|
  json.extract! merchant_alias, :id, :alias, :merchant_id, :financial_institution_id
  json.url merchant_alias_url(merchant_alias, format: :json)
end
