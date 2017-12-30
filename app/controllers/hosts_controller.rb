# frozen_string_literal: true

# Host controller
class HostsController < ApplicationController
  # GET /hosts
  def index
    hosts = Phut::Netns.all
    render json: hosts, status: :ok
  end

  # GET /hosts/name
  def show
    result = Phut::Netns.find_by(name: params[:name])
    code = :ok
    unless result
      result = { error: "no such host: #{params[:name]}" }
      code = :not_found
    end
    render json: result, status: code
  end

  # PUT /hosts/name
  def update
    HostValidator.new(host_params).validate!
    result, error, code = *NetTester::Netns.create(params[:name], host_params), :ok
    if error
      result = { error: error }
      code = :internal_server_error
    end
    render json: result, status: code
  end

  private

  # Only allow a trusted parameter "white list" through.
  def host_params
    params.require(:host).permit(:mac_address, :ip_address, :netmask, :gateway, :virtual_port_number, :physical_port_number, :vlan_id)
  end
end
