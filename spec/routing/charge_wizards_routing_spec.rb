require "spec_helper"

describe ChargeWizardsController do
  describe "routing" do

    it "routes to #index" do
      get("/charge_wizards").should route_to("charge_wizards#index")
    end

    it "routes to #new" do
      get("/charge_wizards/new").should route_to("charge_wizards#new")
    end

    it "routes to #show" do
      get("/charge_wizards/1").should route_to("charge_wizards#show", :id => "1")
    end

    it "routes to #edit" do
      get("/charge_wizards/1/edit").should route_to("charge_wizards#edit", :id => "1")
    end

    it "routes to #create" do
      post("/charge_wizards").should route_to("charge_wizards#create")
    end

    it "routes to #update" do
      put("/charge_wizards/1").should route_to("charge_wizards#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/charge_wizards/1").should route_to("charge_wizards#destroy", :id => "1")
    end

  end
end
