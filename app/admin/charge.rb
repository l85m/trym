ActiveAdmin.register Charge do
  permit_params :description, :amount, :billing_day, :recurring, :recurring_score, 
                :history, :plaid_name, :user_id, :transaction_request_id, :merchant_id,
                :trym_category_id

  config.sort_order = "recurring_score_desc"

  index do
    selectable_column
    column :id
    column "User ID" do |charge|
      if charge.user_id
        link_to charge.user.id, admin_user_path(charge.user.id)
      end
    end
    column :recurring
    column :recurring_score
    column :plaid_name
    column :merchant do |charge|
      if charge.merchant_id
        link_to charge.merchant.name, admin_merchant_path(charge.merchant.id)
      end
    end
    column "Trym Category" do |charge|
      if charge.trym_category_id
        link_to charge.trym_category.name, admin_trym_category_path(charge.trym_category.id)
      else
        nil
      end
    end    
    column "Plaid Category" do |charge|
      if charge.category_id
        link_to charge.category_id, admin_plaid_category_path(charge.plaid_category.id)
      else
        nil
      end
    end
    actions
  end


  filter :name
  filter :description
  filter :merchant
  filter :user
  filter :created_at
  filter :updated_at


end
