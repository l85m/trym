require 'spec_helper'

describe "charges/index" do
  before(:each) do
    assign(:charges, [
      stub_model(Charge,
        :merchant => "MyText",
        :description => "MyText",
        :user => nil,
        :amount => 1,
        :renewal_period_in_days => 2
      ),
      stub_model(Charge,
        :merchant => "MyText",
        :description => "MyText",
        :user => nil,
        :amount => 1,
        :renewal_period_in_days => 2
      )
    ])
  end

  it "renders a list of charges" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
  end
end
