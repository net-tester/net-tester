# frozen_string_literal: true
module NetTester
  class Patch
    def self.create(physical_switch_dpid:,
                    vlan_id:, source_port:, source_mac_address:, destination_port:)
      if vlan_id
        VlanHostToPatchFlow.create(in_port: source_port, vlan_id: vlan_id)
      else
        HostToPatchFlow.create(in_port: source_port)
      end
      PatchToHostFlow.create(destination_mac_address: source_mac_address, out_port: source_port)
      PatchToNetworkFlow.create(source_mac_address: source_mac_address, out_port: destination_port,
                                physical_switch_dpid: physical_switch_dpid)
      NetworkToPatchFlow.create(in_port: destination_port,
                                physical_switch_dpid: physical_switch_dpid)
    end

    def self.all
      HostToPatchFlow.all
      PatchToNetworkFlow.all
      NetworkToPatchFlow.all
      PatchToHostFlow.all

      # host_to_patch = @flow_stats_reply[0xdad1c001].stats.select do |each|
      #   each.match.in_port == 1 &&
      #     each.actions.size == 1 &&
      #     each.actions.first.port == 3
      # end
      # logger.info "host_to_patch #{host_to_patch.inspect}"

      # patch_to_network = @flow_stats_reply[0xdef].stats.select do |each|
      #   # TODO: check the source mac address
      #   each.match.in_port == 3 &&
      #     each.actions.size == 1 &&
      #     each.actions.first.port == 1
      # end
      # logger.info "patch_to_network: #{patch_to_network.inspect}"

      # network_to_patch = @flow_stats_reply[0xdef].stats.select do |each|
      #   each.match.in_port == 1 &&
      #     each.actions.size == 1 &&
      #     each.actions.first.port == 3
      # end
      # logger.info "network_to_patch #{network_to_patch.inspect}"

      # patch_to_host = @flow_stats_reply[0xdad1c001].stats.select do |each|
      #   # TODO: check the dest mac address
      #   each.match.in_port == 3 &&
      #     each.actions.size == 1 &&
      #     each.actions.first.port == 1
      # end
      # logger.info "patch_to_host #{patch_to_host.inspect}"
    end
  end
end
