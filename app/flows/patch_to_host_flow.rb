# frozen_string_literal: true

# Control flows from patch(OVS) to tester-host.
class PatchToHostFlow < ActiveFlow::Base
  def self.create(destination_mac_address:, out_port:)
    send_flow_mod_add(0xdad1c001,
                      priority: NetTester::PRIORITY_MID,
                      match: Match.new(in_port: 1,
                                       destination_mac_address: destination_mac_address),
                      actions: SendOutPort.new(out_port))
  end

  def self.destroy(destination_mac_address:, out_port:)
    send_flow_mod_delete(0xdad1c001,
                         match: Match.new(in_port: 1,
                                          destination_mac_address: destination_mac_address),
                         out_port: out_port)
  end

  def self.all
    flow_stats(0xdad1c001).stats.select do |each|
      each.match.in_port == 1
    end
  end
end
