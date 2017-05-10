class SitesController < ApplicationController
  # GET /sites
  def index
    @sites = []
    render json: @sites
  end

  private
    # Only allow a trusted parameter "white list" through.
    def site_params
      params.fetch(:site, {})
    end
end
