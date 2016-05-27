class NetworkToPatchFlow < ActiveFlow::Base
  def self.create(in_port:)
    send_flow_mod_add(0xdef,
                      match: Match.new(in_port: in_port),
                      actions: SendOutPort.new(Host.all.size + 1))
  end

  def self.all
    flow_stats(0xdef).stats.select do |each|
      each.actions.size == 1 && each.actions.first.port == Host.all.size + 1
    end
  end
end