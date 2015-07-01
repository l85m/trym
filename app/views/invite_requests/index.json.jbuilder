json.array!(@invite_requests) do |invite_request|
  json.extract! invite_request, :id, :email
  json.url invite_request_url(invite_request, format: :json)
end
