json.array!(@linked_accounts) do |linked_account|
  json.extract! linked_account, :id, :user_id, :financial_institution_id, :status, :failure_reason
  json.url linked_account_url(linked_account, format: :json)
end
