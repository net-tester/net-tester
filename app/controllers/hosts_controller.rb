class HostsController < ApplicationController

  # GET /hosts
  def index
    hosts = Phut::Netns.all
    render json: hosts, status: :ok
  end

  # GET /hosts/name
  def show
    result, code = Phut::Netns.find_by(name: params[:name]), :ok
    result, code = {error: "no such host: #{params[:name]}"}, :not_found unless result
    render json: result, status: code
  end

  # PUT /hosts/name
  def update
    HostValidator.new(host_params).validate!
    result, error, code = *NetTester::Netns.create(params[:name], host_params), :ok
    result, code = {error: error}, :internal_server_error if error
    render json: result, status: code
  end

  private

  # Only allow a trusted parameter "white list" through.
  def host_params
    params.require(:host).permit(:mac_address, :ip_address, :netmask, :gateway, :virtual_port_number, :physical_port_number, :vlan_id)
  end
end
