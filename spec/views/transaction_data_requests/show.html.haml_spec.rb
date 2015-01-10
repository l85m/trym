require 'spec_helper'

describe "transaction_data_requests/show" do
  before(:each) do
    @transaction_data_request = assign(:transaction_data_request, stub_model(TransactionDataRequest,
      :user => nil,
      :financial_institution => nil,
      :status => "Status",
      :failure_reason => ""
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(//)
    rendered.should match(//)
    rendered.should match(/Status/)
    rendered.should match(//)
  end
end
