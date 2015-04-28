Plaid.config do |p|
  p.customer_id = Rails.application.secrets.plaid_customer_id
  p.secret = Rails.application.secrets.plaid_secret 
  p.environment_location = 'https://api.plaid.com/'
end