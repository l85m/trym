class AccountLinker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(params, linked_account_id)
    @params = params
    @link = LinkedAccount.find(linked_account_id)
    
    connect_to_plaid
    
    update_linked_account
  end

  private

  def update_linked_account
    linked_account_params = { last_api_response: @user.api_res }

    if @user.api_res['response_code'].between?(200,201)
      linked_account_params.merge!(prep_linked_account_params)
    end
    
    @link.update( linked_account_params )
  end

  def connect_to_plaid
    if @params["mfa_response"].present?
      rebuild_plaid_user
      @user.mfa_authentication(*prep_plaid_mfa_params)
    else
      @user = Plaid.add_user('connect', prep_plaid_params)
    end
  end

  def rebuild_plaid_user
    @user = Plaid::User.new
    @user.access_token = @link.plaid_access_token
    @user.permissions = ['connect']
  end

  def account_linked?
    @user.api_res['response_code'] == 200
  end

  def prep_plaid_params
    new_params = {}
    new_params[:type] = @link.financial_institution.plaid_type
    new_params[:username] = @params["username"]
    new_params[:password] = @params["password"]
    new_params[:options] = JSON.generate({ "login_only" => "true", "webhook" => webhook_endpoint })
    #new_params[:start_date] = "60 days ago"
    new_params[:pin] = @params["pin"] if @params["pin"].present?
    new_params
  end

  def webhook_endpoint
    if Rails.env.production?
      Rails.application.routes.url_helpers.plaid_webhook_linked_accounts_url(host: "trym.io", protocol: "https://")
    else
      Rails.application.routes.url_helpers.plaid_webhook_linked_accounts_url(host: "trym.ngrok.io", protocol: "https://")
    end
  end

  def prep_plaid_mfa_params
    [@params["mfa_response"], @link.financial_institution.plaid_type]
  end

  def prep_linked_account_params
    if @user.api_res['response_code'] == 200
      {
        plaid_access_token: @user.access_token, 
        status: "syncing"
      }
    elsif @user.api_res['response_code'] == 201
      mfa = @user.pending_mfa_questions.first.to_a.flatten
      {
        plaid_access_token: @user.access_token,
        mfa_type: mfa.first,
        mfa_question: mfa.last,
        status: "mfa"
      }
    end
  end

end