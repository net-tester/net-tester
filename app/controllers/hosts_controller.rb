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
    if result.nil? then
      result = {error: "no such host: #{params[:name]}"}
      code = :not_found
    end
    render json: result, status: code
  end

  # PUT /hosts/name
  def update
    HostValidator.new(host_params).validate!

    run_result = run_net_tester
    unless run_result.nil? then
      result = {error: run_result}
      render json: result, status: :internal_server_error
    else
      host = Phut::Netns.find_by(name: params[:name])
      if host.nil? then
        netns_params = host_params.to_h.symbolize_keys
        netns_params[:name] = params[:name]
        netns_params[:virtual_port_number] = netns_params[:virtual_port_number].to_i
        netns_params[:physical_port_number] = netns_params[:physical_port_number].to_i
        netns_params[:vlan_id] = netns_params[:vlan_id].to_i unless netns_params[:vlan_id].nil?
        host = NetTester::Netns.new(netns_params)
      end
      render json: host, status: :ok
    end
  end

  private
    # Only allow a trusted parameter "white list" through.
    def host_params
      params.require(:host).permit(:mac_address, :ip_address, :netmask, :gateway, :virtual_port_number, :physical_port_number, :vlan_id)
    end

   # Run NetTester if that's not running.
   def run_net_tester
    return nil if NetTester.running?
    FileUtils.mkdir_p(NetTester.log_dir)
    FileUtils.mkdir_p(NetTester.pid_dir)
    FileUtils.mkdir_p(NetTester.socket_dir)
    FileUtils.mkdir_p(NetTester.process_dir)
    device = ENV['DEVICE'] || 'eth1'
    dpid = ENV['DPID'].try(&:hex) || 0x123
    NetTester.run(network_device: device, physical_switch_dpid: dpid)
    sleep 2
    nil
   rescue => e
    e
   end
end
