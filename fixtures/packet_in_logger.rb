# frozen_string_literal: true
require 'English'

class PacketInLogger < Trema::Controller
  def packet_in(_dpid, message)
    # TODO: make message#vlan? work
    if Pio::EthernetFrame.read(message.raw_data).ether_type.to_i == Pio::Ethernet::Type::VLAN
      logger.info "PACKET_IN: Port = #{message.in_port}, VLAN ID = #{Pio::Parser.read(message.raw_data).vlan_vid}"
    else
      logger.info "PACKET_IN: Port = #{message.in_port}"
    end
  rescue
    logger.error $ERROR_INFO.inspect
  end
end
