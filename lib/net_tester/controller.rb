# frozen_string_literal: true
class NetTester < Trema::Controller
  def start(args)
    @nhost = args.first.to_i
  end

  def switch_ready(dpid)
    case dpid
    when 0xabc
      @nhost.times do |each|
        send_flow_mod_add(dpid,
                          match: Match.new(in_port: each + 1),
                          actions: [Pio::OpenFlow10::SetVlanVid.new(each + 1), SendOutPort.new(@nhost + 1)])
        send_flow_mod_add(dpid,
                          match: Match.new(in_port: @nhost + 1, vlan_vid: each + 1),
                          actions: [Pio::OpenFlow10::StripVlanHeader.new, SendOutPort.new(each + 1)])
      end
    when 0xdef
      @nhost.times do |each|
        send_flow_mod_add(dpid,
                          match: Match.new(in_port: @nhost + 1, vlan_vid: each + 1),
                          actions: [Pio::OpenFlow10::StripVlanHeader.new, SendOutPort.new(each + 1)])
        send_flow_mod_add(dpid,
                          match: Match.new(in_port: each + 1),
                          actions: [Pio::OpenFlow10::SetVlanVid.new(each + 1), SendOutPort.new(@nhost + 1)])
      end
    end
  end
end
