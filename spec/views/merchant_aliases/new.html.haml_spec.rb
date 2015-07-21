require 'spec_helper'

describe "merchant_aliases/new" do
  before(:each) do
    assign(:merchant_alias, stub_model(MerchantAlias,
      :alias => "MyString",
      :merchant => nil,
      :financial_institution => nil
    ).as_new_record)
  end

  it "renders new merchant_alias form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", merchant_aliases_path, "post" do
      assert_select "input#merchant_alias_alias[name=?]", "merchant_alias[alias]"
      assert_select "input#merchant_alias_merchant[name=?]", "merchant_alias[merchant]"
      assert_select "input#merchant_alias_financial_institution[name=?]", "merchant_alias[financial_institution]"
    end
  end
end
