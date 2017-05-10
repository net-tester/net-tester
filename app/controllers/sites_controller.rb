class SitesController < ApplicationController
  # GET /sites
  def index
    @sites = []
    render json: @sites
  end

  # GET /sites/1
  def show
    @site = {}
    render json: @site
  end

  # DELETE /sites/1
  def destroy
  end

  private
    # Only allow a trusted parameter "white list" through.
    def site_params
      params.fetch(:site, {})
    end
end
