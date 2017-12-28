class MaterialsController < ApplicationController

  # GET /materials
  def index
    render json: Material.all, status: :ok
  end

  # POST /materials
  def create
    Material.create(material_params)
    render json: {}, status: :ok
  end

  private

  # Only allow a trusted parameter "white list" through.
  def material_params
    params.require(:material).permit(:file)
  end
end
