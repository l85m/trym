require 'spec_helper'

describe "invite_requests/edit" do
  before(:each) do
    @invite_request = assign(:invite_request, stub_model(InviteRequest,
      :email => "MyString"
    ))
  end

  it "renders the edit invite_request form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", invite_request_path(@invite_request), "post" do
      assert_select "input#invite_request_email[name=?]", "invite_request[email]"
    end
  end
end
