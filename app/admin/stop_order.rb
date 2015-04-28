ActiveAdmin.register StopOrder do
  permit_params :status, :cancelation_data, :option, :contact_preference, 
                :accept_equipment_return, :fee_limit
  controller do
    def scoped_collection
      StopOrder.with_charge
    end
    def edit
      @page_title = "#{resource.option.titleize} request for #{resource.charge.descriptor} from #{resource.user.name}"
    end
  end
  
  config.sort_order = "created_at.desc"

  index do
    selectable_column
    column :id do |order|
      link_to order.id, admin_stop_order_path(order) 
    end
    column :status
    column :option
    column :user do |order|
      link_to order.user.name, admin_user_path(order.user.id) if order.charge.present?
    end
    column :operator
    column :charge do |order|
      link_to order.charge.descriptor, admin_charge_path(order.charge.id) if order.charge.present?
    end
    column :created_at
  end

  filter :status
  filter :user
  filter :operator
  filter :option
  filter :charge
  filter :created_at
  filter :updated_at

  form do |f|
    f.inputs "Request Info" do 
      input :operator, as: :select, collection: User.admins
      input :status, as: :select, collection: %w(started requested working succeeded failed canceled)
      input :option, as: :select, collection: ["cancel_all", "downgrade", "upgrade", "find_deals", nil]
    end
    f.inputs "User Preferences" do 
      input :contact_preference, as: :select, collection: %w(call text email)
      input :accept_equipment_return
      input :fee_limit, label: "Fee limit in US CENTS"
    end
    f.inputs  "Request data" do 
      input :cancelation_data
    end
    actions
  end

end