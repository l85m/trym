require "spec_helper"

describe MerchantAliasesController do
  describe "routing" do

    it "routes to #index" do
      get("/merchant_aliases").should route_to("merchant_aliases#index")
    end

    it "routes to #new" do
      get("/merchant_aliases/new").should route_to("merchant_aliases#new")
    end

    it "routes to #show" do
      get("/merchant_aliases/1").should route_to("merchant_aliases#show", :id => "1")
    end

    it "routes to #edit" do
      get("/merchant_aliases/1/edit").should route_to("merchant_aliases#edit", :id => "1")
    end

    it "routes to #create" do
      post("/merchant_aliases").should route_to("merchant_aliases#create")
    end

    it "routes to #update" do
      put("/merchant_aliases/1").should route_to("merchant_aliases#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/merchant_aliases/1").should route_to("merchant_aliases#destroy", :id => "1")
    end

  end
end
