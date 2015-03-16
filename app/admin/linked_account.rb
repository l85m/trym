ActiveAdmin.register LinkedAccount do
  
  index do
    selectable_column
    column :id
    column :user
    column :financial_institution
    column :last_successful_sync
    column :last_api_response
    column :destroyed_at
    actions
  end

  filter :user
  filter :financial_institution
  filter :last_successful_sync
  filter :last_api_response
  filter :created_at
  filter :updated_at

end