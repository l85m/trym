json.array!(@account_details) do |account_detail|
  json.extract! account_detail, :id, :user_id, :first_name, :last_name, :phone, :phone_verified_at, :confirmation_code, :account_data
  json.url account_detail_url(account_detail, format: :json)
end
