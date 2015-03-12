ActiveAdmin.register TrymCategory do
  permit_params :name, :description, :recurring

  index do
    selectable_column
    column :name do |category|
      link_to (category.name.present? ? category.name : "n/a"), admin_trym_category_path(category)
    end
    column :id
    column :description
    column :recurring
    column "Plaid Categories" do |category|
      if category.plaid_categories.count > 0
        link_to category.plaid_categories.count, admin_plaid_categories_path(q: {trym_category_id_eq: category.id})
      else
        nil
      end
    end
    column "Merchants" do |category|
      if category.merchants.count > 0
        link_to category.merchants.count, admin_merchants_path(q: {trym_category_id_eq: category.id})
      else
        nil
      end
    end
    column "Charges" do |category|
      if category.charges.count > 0
        link_to category.charges.count, admin_charges_path(q: {trym_category_id_eq: category.id})
      else
        nil
      end    
    end
  end

end
