# frozen_string_literal: true
module NetTester
  class Patch
    # port-to-port patch list, [[port1,port2],[port3,port4],...]
    @p2p_patch_list = []

    def self.raise_by_overlapped_patch(port_id_list)
      port_id_list.each do |port_id|
        if @p2p_patch_list.any? { |patch| patch.include?(port_id) }
          raise "Port #{port_id} is already in use by other patch"
        end
      end
    end

    def self.create(physical_switch_dpid:,
                    vlan_id:, source_port:, source_mac_address:, destination_port:)
      raise_by_overlapped_patch [source_port, destination_port]
      if vlan_id
        VlanHostToPatchFlow.create(in_port: source_port, vlan_id: vlan_id)
        PatchToVlanHostFlow.create(destination_mac_address: source_mac_address, out_port: source_port, vlan_id: vlan_id)
        PatchToVlanHostBroadcastFlow.create(vlan_id: vlan_id)
      else
        HostToPatchFlow.create(in_port: source_port)
        PatchToHostFlow.create(destination_mac_address: source_mac_address, out_port: source_port)
      end
      PatchToNetworkFlow.create(source_mac_address: source_mac_address, out_port: destination_port,
                                physical_switch_dpid: physical_switch_dpid)
      NetworkToPatchFlow.create(in_port: destination_port,
                                physical_switch_dpid: physical_switch_dpid)
    end

    def self.create_p2p(physical_switch_dpid:, source_port:, destination_port:)
      raise_by_overlapped_patch [source_port, destination_port]
      NetworkToNetworkPatchFlow.create(physical_switch_dpid: physical_switch_dpid,
                                       source_port: source_port,
                                       destination_port: destination_port)
      NetworkToNetworkPatchFlow.create(physical_switch_dpid: physical_switch_dpid,
                                       source_port: destination_port,
                                       destination_port: source_port)
      @p2p_patch_list.append [source_port, destination_port]
    end

    def self.destroy(physical_switch_dpid:,
                     vlan_id:, source_port:, source_mac_address:, destination_port:)
      if vlan_id
        VlanHostToPatchFlow.destroy(in_port: source_port, vlan_id: vlan_id)
        PatchToVlanHostFlow.destroy(out_port: source_port, vlan_id: vlan_id)
        PatchToVlanHostBroadcastFlow.destroy(vlan_id: vlan_id)
      end
      HostToPatchFlow.destroy(in_port: source_port)
      PatchToHostFlow.destroy(destination_mac_address: source_mac_address, out_port: source_port)
      PatchToNetworkFlow.destroy(source_mac_address: source_mac_address, out_port: destination_port,
                                 physical_switch_dpid: physical_switch_dpid)
      NetworkToPatchFlow.destroy(in_port: destination_port,
                                 physical_switch_dpid: physical_switch_dpid)
      @p2p_patch_list.clear
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

      # patch_to_network = @flow_stats_reply[0x123].stats.select do |each|
      #   # TODO: check the source mac address
      #   each.match.in_port == 3 &&
      #     each.actions.size == 1 &&
      #     each.actions.first.port == 1
      # end
      # logger.info "patch_to_network: #{patch_to_network.inspect}"

      # network_to_patch = @flow_stats_reply[0x123].stats.select do |each|
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
