# frozen_string_literal: true

# Control vlan-tagged unicast flow from tester-host to patch(OVS).
class VlanHostToPatchFlow < ActiveFlow::Base
  def self.create(in_port:, vlan_id:)
    send_flow_mod_add(0xdad1c001,
                      match: Match.new(in_port: in_port),
                      actions: [SetVlanVid.new(vlan_id), SendOutPort.new(1)])
  end

  def self.destroy(in_port:)
    send_flow_mod_delete(0xdad1c001,
                         match: Match.new(in_port: in_port),
                         out_port: 1)
  end
end
