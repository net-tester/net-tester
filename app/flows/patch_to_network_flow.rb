class PatchToNetworkFlow < ActiveFlow::Base
  def self.create(source_mac_address:, out_port:)
    send_flow_mod_add(0xdef,
                      match: Match.new(in_port: Host.all.size + 1,
                                       source_mac_address: source_mac_address),
                      actions: SendOutPort.new(out_port))
  end
end
