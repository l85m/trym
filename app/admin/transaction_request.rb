ActiveAdmin.register TransactionRequest do
  actions :all, :except => [:edit]

  index do
    selectable_column
    column :id
    column :user do |req|
      if req.linked_account.present? && req.linked_account.user.present?
        link_to req.linked_account.user.name, admin_user_path(req.linked_account.user.id)
      end
    end
    column :linked_account
    column :transaction_count
    column :created_at
    column :updated_at
    actions
  end

  show do
    attributes_table do
      row :user do |req|
        if req.linked_account.present? && req.linked_account.user.present?
          link_to req.linked_account.user.name, admin_user_path(req.linked_account.user.id)
        end
      end
      row :created_at
      row :updated_at
      row :transaction_count
      row :data do |req|
        if req.data.present?
          content_tag :div, req.data, class: 'pretty-json', data: { json: req.data.to_json }
        end
      end
    end
    active_admin_comments
  end

end
