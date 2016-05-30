# frozen_string_literal: true
require 'active_support/core_ext/class/attribute'
require 'phut/shell_runner'
require 'pio'

module Phut
  # Open vSwitch controller
  class Switch
    class_attribute :prefix

    include ShellRunner
    extend ShellRunner

    def self.name_prefix(name)
      self.prefix = name
    end

    name_prefix ''

    def self.all
      sudo('ovs-vsctl list-br').chomp.split.map do |each|
        dpid = ('0x' + sudo("ovs-vsctl get bridge #{each} datapath-id").delete('"')).hex
        case each
        when /^#{prefix}(0x\S+)/
          new(dpid: dpid) if dpid == Regexp.last_match(1).hex
        when /^#{prefix}(\S+)/
          new(name: Regexp.last_match(1), dpid: dpid)
        end
      end.compact
    end

    def self.find_by(queries)
      queries.inject(all) do |memo, (attr, value)|
        memo.find_all { |switch| switch.__send__(attr) == value }
      end.first
    end

    def self.find_by!(queries)
      find_by(queries) || raise("Swtich not found: #{queries.inspect}")
    end

    def self.create(*args)
      new(*args).tap(&:start)
    end

    def self.dump_flows(name)
      find_by!(name: name).dump_flows
    end

    def self.destroy_all
      all.each(&:stop)
    end

    attr_reader :dpid

    def initialize(dpid:, name: nil, port: 6653)
      @dpid = dpid
      @name = name
      @port = port
    end

    def name
      @name || format('%#x', @dpid)
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

    def add_numbered_port(port_number, device)
      add_port device
      sudo "ovs-vsctl set Port #{device} other_config:rstp-port-num=#{port_number}"
    end

    def ports
      sudo("ovs-vsctl list-ports #{bridge_name}").split
    end

    def running?
      system("sudo ovs-vsctl br-exists #{bridge_name}") &&
        !sudo("ovs-vsctl get-controller #{bridge_name}").empty?
    end

    def dump_flows
      output = sudo "ovs-ofctl dump-flows #{bridge_name} -O #{Pio::OpenFlow.version}"
      output.split("\n").inject('') do |memo, each|
        memo + ((/^(NXST|OFPST)_FLOW reply/=~ each) ? '' : each.lstrip + "\n")
      end
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
      self.class.prefix + name
    end

    def dpid_zero_filled
      raise 'DPID is not set' unless @dpid
      hex = format('%x', @dpid)
      '0' * (16 - hex.length) + hex
    end
  end
end
