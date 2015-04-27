class PlaidErrorHandler
  attr_reader :reauth_required, :mfa_reset, :message_for_user

  def initialize(api_response)
    @response_code = api_response['response_code'].to_i
    @error_code = api_response['error_code'].to_i
    @error_message = api_response['error_message']
    @error_resolve = api_response['error_resolve']
    @reauth_required = false
    @mfa_reset = false
    @message_for_user = handle_error
  end

  def handle_error
    if plaid_fault?
      "Something went wrong in the network. Please try again in a few minutes."
    elsif institution_down?
      "We're having trouble reaching your financial institution.  Please try again in a few minutes."
    elsif mfa_reset?
      @mfa_reset = true
      "Your financial institution is asking for some additional information before we can access your account."
    elsif requires_reauth?
      require_reauth
      "Your financial institution is asking for some additional information before we can access your account."
    elsif find_error_message.present?
      find_error_message
    else
      if Rails.env.production? 
        "Sorry - it looks like there's a bug somewhere in our code.  We've been notified.  Please try again later."
      else
        "PLAID API ERROR #{@error_code} :: #{@error_message} - #{@error_resolve}"
      end
    end
  end

  private 

  def find_error_message
    if [1200,1201,1202,1203,1207,1209].include?(@error_code)
      require_reauth
      return "Invalid credentials - please check your account information and try again."
    elsif @error_code == 1005
      require_reauth
      return "Please complete all fields before continueing"
    elsif @error_code == 1205
      require_reauth
      return "Your account appears to be locked.  Please visit your financial institution's website to unlock it."
    elsif @error_code == 1206
      require_reauth
      return "Your account has not been fully set up.  Please visit your financial institution's website and complete your registration."
    elsif [1210,1214,1208,1212].include?(@error_code)
      return "Sorry - this account is not yet compatible with Trym. Please try it again in a few days."
    elsif @error_code == 1211
      require_reauth
      return "The SafePass rules for this Bank of America account restrict external access. To resolve, please login to Bank of America and disable 'Require SafePass to sign in to Online Banking'."
    else
      nil 
    end
  end

  def require_reauth
    @reauth_required = true
  end

  # def trym_fault?
  #   [400,401].include?(@response_code) || [1204,1213,1216].include?(@error_code) || ( @response_code == 404 && @error_code != 1605 )
  # end

  def plaid_fault?
    @response_code.between?(500,600)
  end

  def mfa_reset?
    @error_code == 1215
  end

  def institution_down?
    [1302,1303].include?(@error_code)
  end

  def requires_reauth?
    @error_code == 1605
  end

end