class ProcessesController < ApplicationController

  # GET /processes
  def index
    processes = NetTester::Process.all.values
    render json: processes, status: :ok
  end

  # GET /processes/1
  def show
    id = params[:id].to_i
    result, code = NetTester::Process.find(id), :ok
    result, code = {error: "no such process: #{id}"}, :not_found unless result
    render json: result, status: code
  end

  # POST /processes
  def create
    ProcessValidator.new(process_params).validate!
    result, error, code = *NetTester::Process.create(process_params), :ok
    result, code = {error: error}, :bad_request if error
    render json: result, status: code
  end

  private

  # Only allow a trusted parameter "white list" through.
  def process_params
    params.require(:process).permit(:host_name, :command, :initial_wait, :process_wait)
  end
end
