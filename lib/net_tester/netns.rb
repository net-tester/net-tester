# frozen_string_literal: true

require 'active_support/core_ext/module/delegation'
require 'phut/netns'

module NetTester
  # Phut::Netns wrapper class
  class Netns
    # rubocop:disable ParameterLists
    def initialize(name:,
                   mac_address:,
                   ip_address:,
                   netmask:,
                   gateway:,
                   virtual_port_number:,
                   physical_port_number:)
      @netns = Phut::Netns.create(name: name,
                                  mac_address: mac_address,
                                  ip_address: ip_address,
                                  netmask: netmask,
                                  route: { net: '0.0.0.0', gateway: gateway })
      patch_netns_to_physical_port(virtual_port_number: virtual_port_number,
                                   physical_port_number: physical_port_number)
    end
    # rubocop:enable ParameterLists

    def method_missing(method, *args, &block)
      @netns.__send__ method, *args, &block
    end

    private

    def patch_netns_to_physical_port(virtual_port_number:,
                                     physical_port_number:)
      virtual_port_name = "port#{virtual_port_number}"
      link = Phut::Link.create(@netns.name, virtual_port_name)
      NetTester.connect_device_to_virtual_port(device: link.device(virtual_port_name),
                                               port_number: virtual_port_number)
      NetTester.controller.create_patch(source_port: virtual_port_number,
                                        source_mac_address: @netns.mac_address,
                                        destination_port: physical_port_number)
      @netns.device = link.device(@netns.name)
    end
  end
end
