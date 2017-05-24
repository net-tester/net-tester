class ApplicationController < ActionController::API

  rescue_from Exception, with: :_render_500
  rescue_from ActionController::RoutingError, with: :_render_404

  def routing_error
    raise ActionController::RoutingError, params[:path]
  end

  private

  def _render_404(e = nil)
    render json: {error: 'resource not found'}, status: :not_found
  end

  def _render_500(e = nil)
    render json: {error: 'internal server error'}, status: :internal_server_error
  end

end
