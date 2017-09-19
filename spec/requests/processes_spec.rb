require 'rails_helper'

RSpec.describe "Processes", type: :request do
  describe "GET /processes" do
    it "works! (now write some real specs)" do
      get processes_path
      expect(response).to have_http_status(200)
    end
  end
end
