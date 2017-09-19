require "rails_helper"

RSpec.describe ProcessesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/processes").to route_to("processes#index")
    end


    it "routes to #show" do
      expect(:get => "/processes/1").to route_to("processes#show", :id => "1")
    end


    it "routes to #create" do
      expect(:post => "/processes").to route_to("processes#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/processes/1").to route_to("processes#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/processes/1").to route_to("processes#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/processes/1").to route_to("processes#destroy", :id => "1")
    end

  end
end
