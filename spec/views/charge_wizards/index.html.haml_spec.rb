require 'spec_helper'

describe "charge_wizards/index" do
  before(:each) do
    assign(:charge_wizards, [
      stub_model(ChargeWizard,
        :linked_account => nil,
        :progress => "",
        :in_progress => false
      ),
      stub_model(ChargeWizard,
        :linked_account => nil,
        :progress => "",
        :in_progress => false
      )
    ])
  end

  it "renders a list of charge_wizards" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
  end
end
