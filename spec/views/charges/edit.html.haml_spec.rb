require 'spec_helper'

describe "charges/edit" do
  before(:each) do
    @charge = assign(:charge, stub_model(Charge,
      :merchant => "MyText",
      :description => "MyText",
      :user => nil,
      :amount => 1,
      :renewal_period_in_days => 1
    ))
  end

  it "renders the edit charge form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", charge_path(@charge), "post" do
      assert_select "textarea#charge_merchant[name=?]", "charge[merchant]"
      assert_select "textarea#charge_description[name=?]", "charge[description]"
      assert_select "input#charge_user[name=?]", "charge[user]"
      assert_select "input#charge_amount[name=?]", "charge[amount]"
      assert_select "input#charge_renewal_period_in_days[name=?]", "charge[renewal_period_in_days]"
    end
  end
end
