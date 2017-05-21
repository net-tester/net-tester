class SitesController < ApplicationController
  # GET /sites
  def show
    @site = {}
    render json: @site
  end

  # DELETE /sites
  def destroy
    NetTester.kill
    system('sudo rm -rf /etc/netns/*')
  end
end
