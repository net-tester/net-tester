require 'rails_helper'

RSpec.describe "Hosts", type: :request do
  describe "GET /hosts" do
    it "works! (now write some real specs)" do
      get hosts_path
      expect(response).to have_http_status(200)
    end
  end
end
