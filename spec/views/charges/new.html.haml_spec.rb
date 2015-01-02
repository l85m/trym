require 'spec_helper'

describe "charges/new" do
  before(:each) do
    assign(:charge, stub_model(Charge,
      :merchant => "MyText",
      :description => "MyText",
      :user => nil,
      :amount => 1,
      :renewal_period_in_days => 1
    ).as_new_record)
  end

  it "renders new charge form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", charges_path, "post" do
      assert_select "textarea#charge_merchant[name=?]", "charge[merchant]"
      assert_select "textarea#charge_description[name=?]", "charge[description]"
      assert_select "input#charge_user[name=?]", "charge[user]"
      assert_select "input#charge_amount[name=?]", "charge[amount]"
      assert_select "input#charge_renewal_period_in_days[name=?]", "charge[renewal_period_in_days]"
    end
  end
end
