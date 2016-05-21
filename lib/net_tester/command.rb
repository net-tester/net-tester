# frozen_string_literal: true
require 'net_tester'
require 'trema'

module NetTester
  # net_tester sub-commands
  module Command
    extend Dir

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
