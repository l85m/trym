require 'spec_helper'

describe "merchants/new" do
  before(:each) do
    assign(:merchant, stub_model(Merchant,
      :name => "MyText",
      :type => "MyText"
    ).as_new_record)
  end

  it "renders new merchant form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", merchants_path, "post" do
      assert_select "textarea#merchant_name[name=?]", "merchant[name]"
      assert_select "textarea#merchant_type[name=?]", "merchant[type]"
    end
  end
end
