json.array!(@financial_institutions) do |financial_institution|
  json.extract! financial_institution, :id, :name
end
