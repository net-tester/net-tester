class PatchToNetworkFlow < ActiveFlow::Base
  def self.create(physical_switch_dpid:, source_mac_address:, out_port:)
    send_flow_mod_add(physical_switch_dpid,
                      match: Match.new(in_port: Host.all.size + 1,
                                       source_mac_address: source_mac_address),
                      actions: SendOutPort.new(out_port))
  end

  def self.destroy(physical_switch_dpid:, source_mac_address:, out_port:)
    send_flow_mod_delete(physical_switch_dpid,
                         match: Match.new(in_port: Host.all.size + 1,
                                          source_mac_address: source_mac_address),
                         out_port: out_port)
  end

  def self.all(physical_switch_dpid)
    flow_stats(physical_switch_dpid).stats.select do |each|
      each.match.in_port == Host.all.size + 1
    end
  end
end
