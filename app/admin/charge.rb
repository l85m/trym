ActiveAdmin.register Charge do
  permit_params :description, :amount, :billing_day, :recurring, :recurring_score, 
                :history, :plaid_name, :user_id, :transaction_request_id, :merchant_id,
                :trym_category_id

  config.sort_order = "recurring_score_desc"

  index do
    selectable_column
    column :id do |charge|
      link_to charge.id, admin_charge_path(charge)
    end
    column :user
    column "Linked Account" do |charge|
      if charge.transaction_request_id
        link_to charge.transaction_request.linked_account.account_name, admin_linked_account_path(charge.transaction_request.linked_account)
      else
        nil
      end
    end
    column :recurring
    column :recurring_score
    column "Date of Last Charge" do |charge|
      if charge.history.present?
        charge.history.keys.max
      end
    end
    column "Amount of Last Charge" do |charge|
      if charge.history.present?
        number_to_currency charge.history[charge.history.keys.max].to_f
      end
    end
    column :plaid_name
    column :merchant do |charge|
      if charge.merchant_id
        link_to charge.merchant.name, admin_merchant_path(charge.merchant.id)
      else
        nil
      end
    end
    column :trym_category
    column :plaid_category
  end

  filter :name
  filter :description
  filter :plaid_name
  filter :merchant
  filter :user
  filter :created_at
  filter :updated_at


  show do
    attributes_table do
      row :name
      row :description
      row :user
      row :transaction_request
      row :plaid_name
      row :merchant
      row :user
      row :created_at
      row :updated_at
      row :trym_category
      row :plaid_category
      row :history
      row :recurring_score
      row :reason_for_score
    end
    active_admin_comments
  end

end
