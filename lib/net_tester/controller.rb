# frozen_string_literal: true

# FIXME: Delete the following "$LOAD_PATH..." and "require ..." line
$LOAD_PATH.unshift File.join(__dir__, '..')
require 'active_flow'
require 'net_tester/patch'

# Software patch panel controller
class NetTesterController < Trema::Controller
  include NetTester

  # args0: dpid
  # args1: 'host_name0:vlan_id0,host_name1:vlan_id1,host_name2:vlan_id2,...'
  def start(args)
    @physical_switch_dpid = args.first.to_i
    @vlan_id = (args[1] || '').split(',').each_with_object({}) do |each, hash|
      raise "Invalid argument: #{args.inspect}" unless /host(\d+):(\d+)/=~ each
      hash[Regexp.last_match(1).to_i] = Regexp.last_match(2).to_i
    end
    logger.info "#{name} started"
  end

  def switch_ready(dpid)
    logger.info "Switch #{dpid.to_hex} connected"
  end

  def packet_in(dpid, message)
    logger.info "packet_in: DPID=#{dpid.to_hex}, data=#{message.data.inspect}"
  end

  def create_patch(source_port:, source_mac_address:, destination_port:)
    Patch.create(physical_switch_dpid: @physical_switch_dpid,
                 vlan_id: @vlan_id[source_port],
                 source_port: source_port,
                 source_mac_address: source_mac_address,
                 destination_port: destination_port)
  end

  def destroy_patch(source_port:, source_mac_address:, destination_port:)
    Patch.destroy(physical_switch_dpid: @physical_switch_dpid,
                  source_port: source_port,
                  source_mac_address: source_mac_address,
                  destination_port: destination_port)
  end

  def list_patches
    Patch.all.map(&:to_s).join("\n")
  end
end
