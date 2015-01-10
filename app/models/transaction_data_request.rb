class TransactionDataRequest < ActiveRecord::Base
  belongs_to :user
  belongs_to :financial_institution
  before_create :set_initial_status
  before_update :set_amount_complete

  def self.create_and_start_scan(params)
  	t = self.new(financial_institution_id: params[:financial_institution], user: params[:user])
  	if t.save
  		t.financial_institution.scan(params[:username],params[:password],t.id)
  		t
  	else
  		nil
  	end
  end

  #TODO: find way to get rid of stub functions for forms
  def username
  end

  def password
  end

  private

  def set_initial_status
    self.status = "logging in"
    self.amount_complete = 15
  end

  def set_amount_complete
    self.amount_complete = {
      "getting statement page" => 45,
      "loading past 6 months of data" => 65,
      "analyzing data to find recurring items" => 80,
      "complete" => 100
    }[status]
  end

end
