class TestletsController < ApplicationController

  # GET /testlets
  def index
    render json: Testlet.all, status: :ok
  end

  # POST /testlets
  def create
    Testlet.create(testlet_params)
    render json: {}, status: :ok
  end

  private

  # Only allow a trusted parameter "white list" through.
  def testlet_params
    params.require(:testlet).permit(:file)
  end
end
