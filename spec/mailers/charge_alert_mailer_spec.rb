require "spec_helper"

describe ChargeAlertMailer do
  describe "three_days_before_charge" do
    let(:mail) { ChargeAlertMailer.three_days_before_charge }

    it "renders the headers" do
      mail.subject.should eq("Three days before charge")
      mail.to.should eq(["to@example.org"])
      mail.from.should eq(["from@example.com"])
    end

    it "renders the body" do
      mail.body.encoded.should match("Hi")
    end
  end

end
