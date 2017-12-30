# frozen_string_literal: true

require 'English'

class PacketInLogger < Trema::Controller
  def start(_argv)
    logger.info "#{name} started"
  end

  def switch_ready(dpid)
    logger.info "Switch #{dpid.to_hex} connected"
  end

  def packet_in(dpid, message)
    # TODO: make message#vlan? work
    if Pio::EthernetFrame.read(message.raw_data).ether_type.to_i == Pio::Ethernet::Type::VLAN
      logger.info "PACKET_IN: Port = #{message.in_port}, VLAN ID = #{Pio::Parser.read(message.raw_data).vlan_vid}"
    else
      logger.info "PACKET_IN: Port = #{message.in_port}"
    end
    # flooding without learning/flow-mod
    send_packet_out(dpid, packet_in: message, actions: SendOutPort.new(:flood))
  rescue StandardError
    logger.error $ERROR_INFO.inspect
  end
end
