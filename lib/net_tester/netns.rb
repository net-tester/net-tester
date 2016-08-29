# frozen_string_literal: true

require 'phut/netns'

module NetTester
  # Phut::Netns wrapper class
  class Netns
    # rubocop:disable ParameterLists
    def self.new(name:,
                 mac_address:,
                 ip_address:,
                 netmask:,
                 gateway:,
                 virtual_port_number:,
                 physical_port_number:)
      netns = Phut::Netns.create(name: name,
                                 mac_address: mac_address,
                                 ip_address: ip_address,
                                 netmask: netmask,
                                 route: { net: '0.0.0.0', gateway: gateway })
      NetTester.patch_netns_to_physical_port(netns: netns,
                                             virtual_port_number: virtual_port_number,
                                             physical_port_number: physical_port_number)
      netns
    end
    # rubocop:enable ParameterLists
  end
end
