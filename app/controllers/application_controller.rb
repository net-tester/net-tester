class ApplicationController < ActionController::API

  include ActiveModel::Model

  rescue_from Exception, with: :_render_500
  rescue_from ActionController::RoutingError, with: :_render_404
  rescue_from ActionController::UnpermittedParameters, with: :_render_400
  rescue_from ActiveModel::ValidationError, with: :_render_400

  def routing_error
    raise ActionController::RoutingError, params[:path]
  end

  private

  def _render_400(e = nil)
    render json: {error: "bad request: #{e}"}, status: :bad_request
  end

  def _render_404(e = nil)
    render json: {error: "resource not found: #{e}"}, status: :not_found
  end

  def _render_500(e = nil)
    render json: {error: "internal server error: #{e}"}, status: :internal_server_error
  end

end
