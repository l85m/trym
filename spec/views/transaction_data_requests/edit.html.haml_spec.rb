require 'spec_helper'

describe "transaction_data_requests/edit" do
  before(:each) do
    @transaction_data_request = assign(:transaction_data_request, stub_model(TransactionDataRequest,
      :user => nil,
      :financial_institution => nil,
      :status => "MyString",
      :failure_reason => ""
    ))
  end

  it "renders the edit transaction_data_request form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", transaction_data_request_path(@transaction_data_request), "post" do
      assert_select "input#transaction_data_request_user[name=?]", "transaction_data_request[user]"
      assert_select "input#transaction_data_request_financial_institution[name=?]", "transaction_data_request[financial_institution]"
      assert_select "input#transaction_data_request_status[name=?]", "transaction_data_request[status]"
      assert_select "input#transaction_data_request_failure_reason[name=?]", "transaction_data_request[failure_reason]"
    end
  end
end
