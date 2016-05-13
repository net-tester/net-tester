# frozen_string_literal: true
class NetTester < Trema::Controller
  def start(args)
    @nhost = args.first.to_i
  end

  def create_patch(host_port, dest_port)
    logger.info "New patch: #{host_port}, #{dest_port}"

    send_flow_mod_add(0xabc,
                      match: Match.new(in_port: host_port),
                      actions: [Pio::OpenFlow10::SetVlanVid.new(host_port), SendOutPort.new(@nhost + 1)])
    send_flow_mod_add(0xabc,
                      match: Match.new(in_port: @nhost + 1, vlan_vid: host_port),
                      actions: [Pio::OpenFlow10::StripVlanHeader.new, SendOutPort.new(host_port)])

    send_flow_mod_add(0xdef,
                      match: Match.new(in_port: @nhost + 1, vlan_vid: dest_port),
                      actions: [Pio::OpenFlow10::StripVlanHeader.new, SendOutPort.new(dest_port)])
    send_flow_mod_add(0xdef,
                      match: Match.new(in_port: dest_port),
                      actions: [Pio::OpenFlow10::SetVlanVid.new(dest_port), SendOutPort.new(@nhost + 1)])
  end
end
