class SitesController < ApplicationController
  # GET /sites
  def show
    @site = {}
    render json: @site
  end

  private
    # Only allow a trusted parameter "white list" through.
    def site_params
      params.fetch(:site, {})
    end
end
