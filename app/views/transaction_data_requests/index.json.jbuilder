json.array!(@transaction_data_requests) do |transaction_data_request|
  json.extract! transaction_data_request, :id, :user_id, :financial_institution_id, :status, :failure_reason
  json.url transaction_data_request_url(transaction_data_request, format: :json)
end
