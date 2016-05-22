# frozen_string_literal: true
require 'net_tester/dir'
require 'net_tester/host'
require 'net_tester/link'
require 'net_tester/physical_test_switch'
require 'net_tester/test_switch'
require 'trema'

module NetTester
  # net_tester sub-commands
  module Command
    extend Dir

    def self.send_packet(source_name, dest_name)
      source = Host.find_by(name: source_name)
      dest = Host.find_by(name: dest_name)
      source.send_packet(dest)
    end

    def self.kill
      Switch.destroy_all
      TestSwitch.destroy_all
      PhysicalTestSwitch.destroy_all
      Host.destroy_all
      Link.destroy_all
      begin
        Trema.trema_process('NetTester', socket_dir).killall
      rescue DRb::DRbConnError
        true
      end
    end
  end
end
