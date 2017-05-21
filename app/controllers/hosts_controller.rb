class HostsController < ApplicationController
  # GET /hosts
  def index
    @hosts = Phut::Netns.all
    render json: @hosts
  end

  # GET /hosts/name
  def show
    @host = Phut::Netns.find_by(name: params[:id])
    render json: @host
  end

  # PUT /hosts/name
  def update
    unless NetTester.running? then
      NetTester.log_dir = File.join(Aruba.config.working_directory, 'log')
      NetTester.pid_dir = File.join(Aruba.config.working_directory, 'pids')
      NetTester.socket_dir = File.join(Aruba.config.working_directory, 'sockets')
      device = ENV['DEVICE'] || 'eth1'
      dpid = ENV['DPID'].try(&:hex) || 0x123
      NetTester.run(network_device: device, physical_switch_dpid: dpid)
      sleep 2
    end

    netns_params = host_params.permit!
    netns_params = netns_params.to_h.symbolize_keys
    netns_params[:name] = params[:name]
    @host = NetTester::Netns.new(netns_params)
    render json: @host
  end

  # DELETE /hosts/name
  def destroy
    Phut::Netns.find_by(name: params[:id]).stop
  end

  private
    # Only allow a trusted parameter "white list" through.
    def host_params
      params.fetch(:host, {})
    end
end
