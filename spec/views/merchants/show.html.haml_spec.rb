require 'spec_helper'

describe "merchants/show" do
  before(:each) do
    @merchant = assign(:merchant, stub_model(Merchant,
      :name => "MyText",
      :type => "MyText"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/MyText/)
    rendered.should match(/MyText/)
  end
end
