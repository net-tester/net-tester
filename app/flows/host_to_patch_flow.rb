# frozen_string_literal: true

# Control flows from tester-host to patch(OVS).
class HostToPatchFlow < ActiveFlow::Base
  def self.create(in_port:)
    send_flow_mod_add(0xdad1c001,
                      priority: NetTester::PRIORITY_MID,
                      match: Match.new(in_port: in_port),
                      actions: SendOutPort.new(1))
  end

  def self.destroy(in_port:)
    send_flow_mod_delete(0xdad1c001,
                         match: Match.new(in_port: in_port),
                         out_port: 1)
  end

  def self.all
    flow_stats(0xdad1c001).stats.select do |each|
      each.actions.size == 1 && each.actions.first.port == 1
    end
  end
end
