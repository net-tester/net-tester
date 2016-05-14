# frozen_string_literal: true
require 'net_tester/sh'

module NetTester
  # Open vSwitch controller
  class Switch
    include Sh
    extend Sh

    PREFIX = 'nts'

    def self.all
      sudo('ovs-vsctl list-br').chomp.split.map do |each|
        /^#{PREFIX}(\S+)/ =~ each ? new(dpid: Regexp.last_match(1).hex) : nil
      end.compact
    end

    def self.create(*args)
      new(*args).tap(&:start)
    end

    def self.destroy_all
      all.each(&:stop)
    end

    attr_reader :dpid

    def initialize(dpid:, port: 6653)
      @dpid = dpid
      @port = port
    end

    def start
      add_bridge
      disable_ipv6
      set_openflow_version_and_dpid
      set_controller
      set_fail_mode_secure
    end

    def stop
      del_bridge
    end

    def add_port(device)
      sudo "ovs-vsctl add-port #{bridge_name} #{device}"
    end

    def ports
      sudo("ovs-vsctl list-ports #{bridge_name}").split
    end

    def running?
      system("sudo ovs-vsctl br-exists #{bridge_name}") &&
        !sudo("ovs-vsctl get-controller #{bridge_name}").empty?
    end

    def <=>(other)
      dpid <=> other.dpid
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

    def set_openflow_version_and_dpid
      sudo "ovs-vsctl set bridge #{bridge_name} protocols=OpenFlow10 other-config:datapath-id=#{dpid_zero_filled}"
    end

    def set_controller
      sudo "ovs-vsctl set-controller #{bridge_name} tcp:127.0.0.1:#{@port} -- set controller #{bridge_name} connection-mode=out-of-band"
    end

    def set_fail_mode_secure
      sudo "ovs-vsctl set-fail-mode #{bridge_name} secure"
    end

    def bridge_name
      raise 'DPID is not set' unless @dpid
      PREFIX + format('%#x', @dpid)
    end

    def dpid_zero_filled
      raise 'DPID is not set' unless @dpid
      hex = format('%x', @dpid)
      '0' * (16 - hex.length) + hex
    end
  end
end
