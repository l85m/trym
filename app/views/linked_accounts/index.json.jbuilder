json.array!(@linked_accounts) do |linked_account|
  json.extract! linked_account, :id, :user_id, :financial_institution_id, :plaid_access_token, :last_successful_sync, :last_api_response, :mfa_question, :mfa_type, :destroyed_at, :status
  json.url linked_account_url(linked_account, format: :json)
end
