json.array!(@charge_wizards) do |charge_wizard|
  json.extract! charge_wizard, :id, :progress, :in_progress, :user_id
  json.url charge_wizard_url(charge_wizard, format: :json)
end
