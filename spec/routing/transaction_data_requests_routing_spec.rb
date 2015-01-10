require "spec_helper"

describe TransactionDataRequestsController do
  describe "routing" do

    it "routes to #index" do
      get("/transaction_data_requests").should route_to("transaction_data_requests#index")
    end

    it "routes to #new" do
      get("/transaction_data_requests/new").should route_to("transaction_data_requests#new")
    end

    it "routes to #show" do
      get("/transaction_data_requests/1").should route_to("transaction_data_requests#show", :id => "1")
    end

    it "routes to #edit" do
      get("/transaction_data_requests/1/edit").should route_to("transaction_data_requests#edit", :id => "1")
    end

    it "routes to #create" do
      post("/transaction_data_requests").should route_to("transaction_data_requests#create")
    end

    it "routes to #update" do
      put("/transaction_data_requests/1").should route_to("transaction_data_requests#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/transaction_data_requests/1").should route_to("transaction_data_requests#destroy", :id => "1")
    end

  end
end
