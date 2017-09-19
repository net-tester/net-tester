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
      result = {error: "no such process: #{id}"}
      code = :not_found
    end
    render json: result, status: code
  end

  # POST /processes
  def create
    ProcessValidator.new(process_params).validate!

    host_name = process_params[:host_name]
    if Phut::Netns.find_by(name: host_name)
      args = process_params.to_h.symbolize_keys
      args[:initial_wait] = args[:initial_wait].to_i unless args[:initial_wait].nil?
      args[:process_wait] = args[:process_wait].to_i unless args[:process_wait].nil?
      command = args.delete(:command)
      process = NetTester::Process.new(args)
      process.exec(command)
      render json: process, status: :ok
    else
      result = {error: "no such host: #{host_name}"}
      render json: result, status: :bad_request
    end
  end

  private
    # Only allow a trusted parameter "white list" through.
    def process_params
      params.require(:process).permit(:host_name, :command, :initial_wait, :process_wait)
    end
end
