# frozen_string_literal: true
class NetTesterController < Trema::Controller
  include Pio::OpenFlow10 # FIXME

  def start(args)
    @nhost = args.first.to_i
    @vlan = (args[1] || '').split(',').each_with_object({}) do |each, hash|
      host_id, vlan_id = each.split(':').map(&:to_i)
      hash[host_id] = vlan_id
    end
    logger.info "#{name} started: nhost = #{@nhost}, vlan = #{@vlan}"
  end

  def switch_ready(dpid)
    logger.info "Switch #{dpid.to_hex} connected"
  end

  # rubocop:disable AbcSize
  # rubocop:disable MethodLength
  def create_patch(host_port, mac_address, dest_port)
    logger.info "New patch: #{host_port}, #{mac_address}, #{dest_port}, #{@vlan[host_port]}"

    if @vlan[host_port]
      send_flow_mod_add(0xabc,
                        match: Match.new(in_port: host_port),
                        actions: [SetVlanVid.new(@vlan[host_port]), SendOutPort.new(@nhost + 1)])
    else
      send_flow_mod_add(0xabc,
                        match: Match.new(in_port: host_port),
                        actions: SendOutPort.new(@nhost + 1))
    end
    send_flow_mod_add(0xabc,
                      match: Match.new(in_port: @nhost + 1, destination_mac_address: mac_address),
                      actions: SendOutPort.new(host_port))

    send_flow_mod_add(0xdef,
                      match: Match.new(in_port: @nhost + 1, source_mac_address: mac_address),
                      actions: SendOutPort.new(dest_port))
    send_flow_mod_add(0xdef,
                      match: Match.new(in_port: dest_port),
                      actions: SendOutPort.new(@nhost + 1))
  end
  # rubocop:enable AbcSize
  # rubocop:enable MethodLength
end
