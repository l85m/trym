ActiveAdmin.register Merchant do
  menu priority: 1
  permit_params :name, :validated, :trym_category_id, :cancelation_fields, :recurring_score
  
  scope :validated
  scope :not_validated
  scope :categorized
  scope :not_categorized

  config.sort_order = "validated_desc"
  
  controller do
    def scoped_collection
      super.includes :trym_category
    end
  end

  batch_action :validate do |ids|
    Merchant.find(ids).each do |merchant|
      merchant.update( validated: true )
    end
    redirect_to admin_merchants_path
  end

  TrymCategory.all.each do |category|
    batch_action "assign_category_to_#{category.name.gsub(/\W/,"").underscore}_for".to_sym do |ids|
      Merchant.find(ids).each do |merchant|
        merchant.update( trym_category_id: category.id )
      end
    redirect_to admin_merchants_path
    end
  end

  index do
    selectable_column
    column :name do |merchant|
      link_to (merchant.name.present? ? merchant.name : "n/a"), admin_merchant_path(merchant)
    end
    column :id
    column :validated
    column :trym_category do |merchant|
      if merchant.trym_category
        link_to merchant.trym_category.name, admin_trym_category_path(merchant)
      else
        nil
      end
    end
    column :cancelation_fields, sortable: :cancelation_fields do |merchant|
      merchant.cancelation_fields.present? ? merchant.cancelation_fields.join(", ") : nil
    end
    column :recurring_score
    column "# Charges" do |merchant|
      if merchant.charges.count > 0
        link_to merchant.charges.count, admin_charges_path(q: {merchant_id_eq: merchant.id})
      else
        nil
      end    
    end
  end

  filter :name
  filter :trym_category
  filter :cancelation_fields
  filter :recurring_score
  filter :created_at
  filter :updated_at

end
