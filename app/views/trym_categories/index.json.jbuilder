json.array!(@trym_categories) do |trym_category|
  json.extract! trym_category, :id, :name, :recurring, :description
  json.url trym_category_url(trym_category, format: :json)
end
