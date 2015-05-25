ActiveAdmin.register StopOrder do
  controller do
    def scoped_collection
      StopOrder.with_charge
    end
    def edit
      @page_title = "#{resource.option.titleize} request for #{resource.charge.descriptor} from #{resource.user.name}"
    end

    def update(options={}, &block)
      resource.update! permitted_params
      update!
    end

    def permitted_params
      p = params.require(:stop_order).permit!
      p["cancelation_data"] = JSON.parse p["cancelation_data"] if p["cancelation_data"].is_a?(String)
      p
    end
  end
  
  config.sort_order = "created_at.desc"

  index do
    selectable_column
    column :id, sortable: :id do |order|
      link_to order.id, admin_stop_order_path(order) 
    end
    column :status
    column :option
    column :user do |order|
      link_to order.user.name, admin_user_path(order.user.id) if order.charge.present?
    end
    column :operator
    column :charge do |order|
      link_to "#{order.charge.id}: #{order.charge.descriptor}", admin_charge_path(order.charge.id) if order.charge.present?
    end
    column :request_age, sortable: :created_at do |order|
      content_tag :span, time_ago_in_words(order.created_at), class: order_age_class(order)
    end
  end

  filter :status
  filter :user
  filter :operator
  filter :option
  filter :charge
  filter :created_at
  filter :updated_at

  show do
    attributes_table do
      row :id
      row :request_age do |order|
        content_tag :span, time_ago_in_words(order.created_at), class: order_age_class(order)
      end
      row :user do |order|
        link_to order.user.name, admin_user_path(order.user.id) if order.charge.present?
      end
      row :operator
      row :status
      row :option
      row :charge do |order|
        link_to "#{order.charge.id}: #{order.charge.descriptor}", admin_charge_path(order.charge.id) if order.charge.present?
      end
      row :cancelation_data do |order|
        if order.cancelation_data.present?
          content_tag :div, order.cancelation_data, class: 'pretty-json', data: { json: order.cancelation_data.to_json }
        end
      end
    end
    active_admin_comments
  end

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
      input :cancelation_data, as: :hstore
    end
    actions
  end

end