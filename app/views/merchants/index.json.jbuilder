json.array!(@merchants) do |merchant|
  json.extract! merchant, :id, :name
end
