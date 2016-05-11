# frozen_string_literal: true
require 'active_support/core_ext/class/attribute_accessors'

module NetTester
  # Open vSwitch controller
  class Switch
    cattr_accessor(:all, instance_reader: false) { [] }

    def self.create(*args)
      all << new(*args)
    end

    def self.destroy_all
      all.each(&:stop)
      all.clear
    end

    def initialize(dpid:, port: 6653)
      @dpid = dpid
      @port = port
      @devices = []
    end

    def add_port(device)
      @devices << device
    end

    def start
      add_bridge
      disable_ipv6
      add_devices
      set_openflow_version_and_dpid
      set_controller
      set_fail_mode_secure
    end

    def stop
      return unless running?
      del_bridge
      @devices.clear
    end

    private

    def add_bridge
      sudo "ovs-vsctl add-br #{bridge_name}"
    end

    def del_bridge
      sudo "ovs-vsctl del-br #{bridge_name}"
    end

    def disable_ipv6
      sudo "/sbin/sysctl -w net.ipv6.conf.#{bridge_name}.disable_ipv6=1 -q"
    end

    def add_devices
      @devices.each { |each| add_device(each) }
    end

    def add_device(device)
      sudo "ovs-vsctl add-port #{bridge_name} #{device}"
    end

    def set_openflow_version_and_dpid
      sudo "ovs-vsctl set bridge #{bridge_name} protocols=OpenFlow10 other-config:datapath-id=#{dpid_zero_filled}"
    end

    def set_controller
      sudo "ovs-vsctl set-controller #{bridge_name} tcp:127.0.0.1:#{@port} -- set controller #{bridge_name} connection-mode=out-of-band"
    end

    def set_fail_mode_secure
      sudo "ovs-vsctl set-fail-mode #{bridge_name} secure"
    end

    def running?
      system "sudo ovs-vsctl br-exists #{bridge_name}"
    end

    def bridge_name
      raise 'DPID is not set' unless @dpid
      'br' + format('%#x', @dpid)
    end

    def dpid_zero_filled
      raise 'DPID is not set' unless @dpid
      hex = format('%x', @dpid)
      '0' * (16 - hex.length) + hex
    end

    def sudo(command)
      sh "sudo #{command}"
    end

    def sh(command)
      system(command) || raise("#{command} failed.")
    end
  end
end
