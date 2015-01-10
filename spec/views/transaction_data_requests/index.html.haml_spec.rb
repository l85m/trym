require 'spec_helper'

describe "transaction_data_requests/index" do
  before(:each) do
    assign(:transaction_data_requests, [
      stub_model(TransactionDataRequest,
        :user => nil,
        :financial_institution => nil,
        :status => "Status",
        :failure_reason => ""
      ),
      stub_model(TransactionDataRequest,
        :user => nil,
        :financial_institution => nil,
        :status => "Status",
        :failure_reason => ""
      )
    ])
  end

  it "renders a list of transaction_data_requests" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => "Status".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
  end
end
