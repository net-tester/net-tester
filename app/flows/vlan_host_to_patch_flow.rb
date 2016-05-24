class VlanHostToPatchFlow < ActiveFlow::Base
  def self.create(in_port:, vlan_id:)
    send_flow_mod_add(0xabc,
                      match: Match.new(in_port: in_port),
                      actions: [SetVlanVid.new(vlan_id),
                                SendOutPort.new(Host.all.size + 1)])
  end
end
