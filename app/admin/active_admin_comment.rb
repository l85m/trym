ActiveAdmin.register ActiveAdmin::Comment do
  menu false
  permit_params :body

  controller do
    def update
      update! do |format|
        format.html { redirect_to send("admin_#{resource.resource_type.gsub(/\W/,'').gsub(/\W/,"").underscore}_path",resource.resource_id) }
      end
    end
  end

  form do |f|
    f.inputs :body
    actions
  end


end
