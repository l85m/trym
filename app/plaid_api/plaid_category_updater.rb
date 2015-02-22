class PlaidCategoryUpdater
  include Sidekiq::Worker

  def perform
    Plaid.category.each do |plaid_type, hierarchy, plaid_id|
      PlaidCategory.find_or_create_by(plaid_id: plaid_id).update( plaid_type: plaid_type, hierarchy: hierarchy )
    end
  end

end