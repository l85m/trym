class ChangeTrymCategoryNames < ActiveRecord::Migration
  def up
		TrymCategory.find_by_name("TV, Phone, & Internet Providers").update(name: "TV, Phone, & Internet")
		t = TrymCategory.find_by_name("Storage, Utilities, Mortgage & Rent")
		t.charges.update_all( trym_category_id: TrymCategory.find_by_name("Home Services & Security") )
		t.delete
		TrymCategory.create( name: "Other", recurring: true, description: "All other recurring expenses" )
  end

  def down
  	TrymCategory.find_by_name("TV, Phone, & Internet").update("TV, Phone, & Internet Providers")
  	TrymCategory.create( name: "Storage, Utilities, Mortgage & Rent", recurring: true, description: "Public Storage, Power, Water, Gas, Rent, Mortgage Payments" )
  end

end
