class PlaidFinancialInstitutionUpdater
  include Sidekiq::Worker

  def perform
    Plaid.institution.each do |plaid_id, name, plaid_type, has_mfa, mfa|
      fin = FinancialInstitution.find_or_create_by(plaid_id: plaid_id)
      fin.update( name: name, plaid_type: plaid_type, has_mfa: has_mfa, mfa: mfa, connect: connect_enabled?(plaid_type))
    end
  end


  def connect_enabled?(plaid_type)
    credentials = {username: "plaid_test", password: "plaid_good", type: plaid_type}
    credentials.merge!({pin: 1234}) if plaid_type == "usaa" 

    Plaid.add_user('connect', credentials).api_res["error_code"] != 1601
  end

end