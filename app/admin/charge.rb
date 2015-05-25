ActiveAdmin.register Charge do
  permit_params :description, :amount, :billing_day, :recurring, :recurring_score, 
                :history, :plaid_name, :user_id, :transaction_request_id, :merchant_id,
                :trym_category_id

  config.sort_order = "recurring_score_desc"

  batch_action :clear_merchant do |ids|
    Charge.find(ids).each { |c| c.update( merchant: nil ) }
    redirect_to collection_path, notice: "merchant on #{ids} cleared"
  end

  batch_action :change_category, form: {
    new_trym_category_id: :text
  } do |ids, inputs|
    Charge.find(ids).each { |c| c.update( trym_category_id: inputs[:new_trym_category_id] ) }
    redirect_to collection_path, notice: [ids, inputs].to_s
  end

  batch_action :change_score, form: {
    new_score: :text
  } do |ids, inputs|
    Charge.find(ids).each { |c| c.update( recurring_score: inputs[:new_score] ) }
    redirect_to collection_path, notice: [ids, inputs].to_s
  end

  index do
    selectable_column
    column :id do |charge|
      link_to charge.id, admin_charge_path(charge)
    end
    column :user
    column "Linked Account" do |charge|
      if charge.transaction_request_id && charge.transaction_request.linked_account
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
      row :merchant do |charge|
        if charge.merchant.present?
          link_to charge.merchant.name, admin_merchant_path(charge.merchant.id)
        end
      end
      row :trym_category
      row :plaid_category
      row :user do |charge|
        if charge.user.present?
          link_to charge.user.name, admin_user_path(charge.user.id)
        end
      end
      row :transaction_request do |charge|
        if charge.transaction_request.present?
          link_to "#{charge.transaction_request.name} > #{charge.transaction_request.id}", admin_transaction_request_path(charge.transaction_request.id)
        end
      end
      row :plaid_name
      row :created_at
      row :updated_at
      row :history do |charge|
        if charge.history.present?
          content_tag :div, charge.history, class: 'pretty-json', data: { json: charge.history.to_json }
        end
      end
      row :recurring_score
      row :reason_for_score do |charge|
        if charge.reason_for_score.present?
          content_tag :div, charge.reason_for_score, class: 'pretty-json', data: { json: charge.reason_for_score.to_json }
        end
      end
    end
    active_admin_comments
  end

  form do |f|
    f.inputs "Charge Info" do 
      input :name, as: :string
      input :description, as: :string
      input :user
      input :option, as: :select, collection: ["cancel_all", "downgrade", "upgrade", "find_deals", nil]
    end
    f.inputs "User Preferences" do 
      input :contact_preference, as: :select, collection: %w(call text email)
      input :accept_equipment_return
      input :fee_limit, label: "Fee limit in US CENTS"
    end
    f.inputs  "Request data" do 
      input :cancelation_data, as: :hstore
    end
    actions
  end

end
