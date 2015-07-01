json.array!(@transaction_requests) do |transaction_request|
  json.extract! transaction_request, :id, :linked_account_id, :data
  json.url transaction_request_url(transaction_request, format: :json)
end
