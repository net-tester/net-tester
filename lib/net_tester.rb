# frozen_string_literal: true
require 'net_tester/command'
require 'net_tester/test_switch'
require 'phut'
require 'trema'

# Base module
module NetTester
  def self.creaate_patch(source_port:, source_mac_address:, destination_port:)
    Trema.trema_process('NetTesterController', Phut.socket_dir).controller
         .create_patch(source_port: source_port,
                       source_mac_address: source_mac_address,
                       destination_port: destination_port)
  end
end
