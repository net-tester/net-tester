require "rails_helper"

RSpec.describe SitesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/sites").to route_to("sites#index")
    end

  end
end
