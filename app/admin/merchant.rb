ActiveAdmin.register Merchant do
  begin
  menu priority: 1
  permit_params :name, :validated, :trym_category_id, :cancelation_fields, :recurring_score
  
  scope :validated
  scope :not_validated
  scope :categorized
  scope :not_categorized

  batch_action :append_to_name, form: {
    append_this: :text
  } do |ids, inputs|
    Merchant.where(id: ids).each{ |m| m.update!( name: m.name + inputs[:append_this] )}
    redirect_to collection_path, notice: [ids, inputs].to_s
  end

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
      merchant.cancelation_fields.present? ? merchant.cancelation_fields.keys.join(", ") : nil
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

  show do
    attributes_table do
      row :name
      row :validated
      row :recurring_score
      row :trym_category
      row :cancelation_fields do |merc|
        if merc.cancelation_fields.present?
          content_tag :div, merc.cancelation_fields, class: 'pretty-json', data: { json: merc.cancelation_fields.to_json }
        end
      end
    end
    active_admin_comments
  end

  form do |f|
    f.inputs "Merc Info" do 
      input :name, as: :string
      input :validated
      input :recurring_score
      input :trym_category
      input :cancelation_fields, as: :hstore
    end
    actions
  end
rescue
  p "active admin is not happy"
end
