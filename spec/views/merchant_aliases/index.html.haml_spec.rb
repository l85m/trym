require 'spec_helper'

describe "merchant_aliases/index" do
  before(:each) do
    assign(:merchant_aliases, [
      stub_model(MerchantAlias,
        :alias => "Alias",
        :merchant => nil,
        :financial_institution => nil
      ),
      stub_model(MerchantAlias,
        :alias => "Alias",
        :merchant => nil,
        :financial_institution => nil
      )
    ])
  end

  it "renders a list of merchant_aliases" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Alias".to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
  end
end
