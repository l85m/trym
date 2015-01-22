require "spec_helper"

describe InviteRequestsController do
  describe "routing" do

    it "routes to #index" do
      get("/invite_requests").should route_to("invite_requests#index")
    end

    it "routes to #new" do
      get("/invite_requests/new").should route_to("invite_requests#new")
    end

    it "routes to #show" do
      get("/invite_requests/1").should route_to("invite_requests#show", :id => "1")
    end

    it "routes to #edit" do
      get("/invite_requests/1/edit").should route_to("invite_requests#edit", :id => "1")
    end

    it "routes to #create" do
      post("/invite_requests").should route_to("invite_requests#create")
    end

    it "routes to #update" do
      put("/invite_requests/1").should route_to("invite_requests#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/invite_requests/1").should route_to("invite_requests#destroy", :id => "1")
    end

  end
end
