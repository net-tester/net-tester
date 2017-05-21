require "rails_helper"

RSpec.describe HostsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/hosts").to route_to("hosts#index")
    end


    it "routes to #show" do
      expect(:get => "/hosts/1").to route_to("hosts#show", :id => "1")
    end


    it "routes to #create" do
      expect(:post => "/hosts").to route_to("hosts#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/hosts/1").to route_to("hosts#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/hosts/1").to route_to("hosts#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/hosts/1").to route_to("hosts#destroy", :id => "1")
    end

  end
end
