require 'spec_helper'

describe "charge_wizards/new" do
  before(:each) do
    assign(:charge_wizard, stub_model(ChargeWizard,
      :linked_account => nil,
      :progress => "",
      :in_progress => false
    ).as_new_record)
  end

  it "renders new charge_wizard form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", charge_wizards_path, "post" do
      assert_select "input#charge_wizard_linked_account[name=?]", "charge_wizard[linked_account]"
      assert_select "input#charge_wizard_progress[name=?]", "charge_wizard[progress]"
      assert_select "input#charge_wizard_in_progress[name=?]", "charge_wizard[in_progress]"
    end
  end
end
