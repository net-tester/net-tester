# frozen_string_literal: true

# FIXME: Delete the following "$LOAD_PATH..." and "require ..." line
$LOAD_PATH.unshift File.join(__dir__, '..')
require 'active_flow'

# Software patch panel controller
class NetTesterController < Trema::Controller
  # args = ['host_name0:vlan_id0,host_name1:vlan_id1,host_name2:vlan_id2,...']
  def start(args)
    @vlan = (args.first || '').split(',').each_with_object({}) do |each, hash|
      raise "Invalid argument: #{args.inspect}" unless /host(\d+):(\d+)/=~ each
      hash[Regexp.last_match(1).to_i] = Regexp.last_match(2).to_i
    end
    logger.info "#{name} started"
  end

  def switch_ready(dpid)
    logger.info "Switch #{dpid.to_hex} connected"
  end

  def create_patch(source_port:, source_mac_address:, destination_port:)
    if @vlan[source_port]
      VlanHostToPatchFlow.create(in_port: source_port,
                                 vlan_id: @vlan[source_port])
    else
      HostToPatchFlow.create(in_port: source_port)
    end
    PatchToHostFlow.create(destination_mac_address: source_mac_address,
                           out_port: source_port)
    PatchToNetworkFlow.create(source_mac_address: source_mac_address,
                              out_port: destination_port)
    NetworkToPatchFlow.create(in_port: destination_port)
  end
end
