json.array!(@charge_wizards) do |charge_wizard|
  json.extract! charge_wizard, :id, :linked_account_id, :progress, :in_progress
  json.url charge_wizard_url(charge_wizard, format: :json)
end
