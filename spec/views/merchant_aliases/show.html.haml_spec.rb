require 'spec_helper'

describe "merchant_aliases/show" do
  before(:each) do
    @merchant_alias = assign(:merchant_alias, stub_model(MerchantAlias,
      :alias => "Alias",
      :merchant => nil,
      :financial_institution => nil
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Alias/)
    rendered.should match(//)
    rendered.should match(//)
  end
end
