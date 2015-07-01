json.array!(@notes) do |note|
  json.extract! note, :id, :noteable_id, :noteable_type, :body, :user_id
  json.url note_url(note, format: :json)
end
