class ChangeTrymCategoryNames < ActiveRecord::Migration
  def up
		t = TrymCategory.find_by_name("TV, Phone, & Internet Providers")
    if t.present? 
      t.update(name: "TV, Phone, & Internet")
    end

		t = TrymCategory.find_by_name("Storage, Utilities, Mortgage & Rent")
		if t.present?
      t.charges.update_all( trym_category_id: TrymCategory.find_by_name("Home Services & Security") )
  		t.delete
    end
		
    TrymCategory.create( name: "Other", recurring: true, description: "All other recurring expenses" ) unless TrymCategory.find_by_name("Other").present?
  end

  def down
  	t = TrymCategory.find_by_name("TV, Phone, & Internet")
    if t.present?
      t.update("TV, Phone, & Internet Providers")
    end
  	TrymCategory.create( name: "Storage, Utilities, Mortgage & Rent", recurring: true, description: "Public Storage, Power, Water, Gas, Rent, Mortgage Payments" )
  end

end
