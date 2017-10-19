# frozen_string_literal: true

require 'active_support/core_ext/module/delegation'
require 'phut/netns'

module NetTester
  # Phut::Netns wrapper class
  class Netns

    @@mutex = Mutex.new

    def self.create(name, host_params)
      run_result = true
      @@mutex.synchronize do
        run_result = run_net_tester
        if run_result
          return nil, run_result
        else
          host = Phut::Netns.find_by(name: name)
          unless host
            netns_params = host_params.to_h.symbolize_keys
            netns_params[:name] = name
            netns_params[:virtual_port_number] = netns_params[:virtual_port_number].to_i
            netns_params[:physical_port_number] = netns_params[:physical_port_number].to_i
            netns_params[:vlan_id] = netns_params[:vlan_id].to_i unless netns_params[:vlan_id].nil?
            host = NetTester::Netns.new(netns_params)
          end
          return host, nil
        end
      end
    end

    # rubocop:disable ParameterLists
    def initialize(name:,
                   mac_address:,
                   ip_address:,
                   netmask:,
                   gateway:,
                   virtual_port_number:,
                   physical_port_number:,
                   vlan_id: nil)
      @netns = Phut::Netns.create(name: name,
                                  mac_address: mac_address,
                                  ip_address: ip_address,
                                  netmask: netmask,
                                  route: { net: '0.0.0.0', gateway: gateway })
      @virtual_port_number = virtual_port_number
      @physical_port_number = physical_port_number
      @vlan_id = vlan_id
      patch_netns_to_physical_port
    end
    # rubocop:enable ParameterLists

    def method_missing(method, *args, &block)
      @netns.__send__ method, *args, &block
    end

    private

    # Run NetTester if that's not running.
    def self.run_net_tester
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

    def patch_netns_to_physical_port
      virtual_port_name = "port#{@virtual_port_number}"
      link = Phut::Link.create(@netns.name, virtual_port_name)
      NetTester.connect_device_to_virtual_port(device: link.device(virtual_port_name),
                                               port_number: @virtual_port_number)
      NetTester.controller.create_patch(source_port: @virtual_port_number,
                                        source_mac_address: @netns.mac_address,
                                        destination_port: @physical_port_number,
                                        vlan_id: @vlan_id)
      @netns.device = link.device(@netns.name)
      @netns.exec("ethtool -K #{@netns.device} tx off")
    end
  end
end
