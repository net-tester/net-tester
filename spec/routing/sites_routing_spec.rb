require "rails_helper"

RSpec.describe SitesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/sites").to route_to("sites#index")
    end

    it "routes to #show" do
      expect(:get => "/sites/1").to route_to("sites#show", :id => "1")
    end

  end
end
