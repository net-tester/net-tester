# frozen_string_literal: true

# Control vlan-tagged unicast flow from patch(OVS) to tester-host.
class PatchToVlanHostFlow < ActiveFlow::Base
  def self.create(destination_mac_address:, out_port:, vlan_id:)
    send_flow_mod_add(0xdad1c001,
                      priority: NetTester::PRIORITY_MID,
                      match: Match.new(in_port: 1,
                                       destination_mac_address: destination_mac_address,
                                       vlan_vid: vlan_id),
                      actions: [StripVlanHeader.new, SendOutPort.new(out_port)])
  end

  def self.destroy(destination_mac_address:, out_port:, vlan_id:)
    send_flow_mod_delete(0xdad1c001,
                         match: Match.new(in_port: 1,
                                          destination_mac_address: destination_mac_address,
                                          vlan_vid: vlan_id),
                         out_port: out_port)
  end
end
