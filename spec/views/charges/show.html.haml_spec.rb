require 'spec_helper'

describe "charges/show" do
  before(:each) do
    @charge = assign(:charge, stub_model(Charge,
      :merchant => "MyText",
      :description => "MyText",
      :user => nil,
      :amount => 1,
      :renewal_period_in_days => 2
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/MyText/)
    rendered.should match(/MyText/)
    rendered.should match(//)
    rendered.should match(/1/)
    rendered.should match(/2/)
  end
end
