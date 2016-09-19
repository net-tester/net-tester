class PatchToVlanHostBroadcastFlow < ActiveFlow::Base
  def self.create(vlan_id:)
    send_flow_mod_add(0xdad1c001,
                      priority: 0x2,
                      match: Match.new(in_port: 1,
                                       destination_mac_address: 'ff:ff:ff:ff:ff:ff',
                                       vlan_vid: vlan_id),
                      actions: [StripVlanHeader.new, SendOutPort.new(:flood)])
  end

  def self.destroy(vlan_id)
    send_flow_mod_delete(0xdad1c001,
                         match: Match.new(in_port: 1,
                                          destination_mac_address: 'ff:ff:ff:ff:ff:ff',
                                          vlan_vid: vlan_id))
  end
end
