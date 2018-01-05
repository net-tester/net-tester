# frozen_string_literal: true

# Process controller
class ProcessesController < ApplicationController
  # GET /processes
  def index
    processes = NetTester::Process.all.values
    render json: processes, status: :ok
  end

  # GET /processes/1
  def show
    id = params[:id].to_i
    result = NetTester::Process.find(id)
    code = :ok
    unless result
      result = { error: "no such process: #{id}" }
      code = :not_found
    end
    render json: result, status: code
  end

  # POST /processes
  def create
    ProcessValidator.new(process_params).validate!
    result, error, code = *NetTester::Process.create(process_params), :ok
    if error
      result = { error: error }
      code = :bad_request
    end
    render json: result, status: code
  end

  private

  # Only allow a trusted parameter "white list" through.
  def process_params
    params.require(:process).permit(:host_name, :command, :initial_wait, :process_wait)
  end
end
