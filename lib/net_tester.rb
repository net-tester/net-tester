# frozen_string_literal: true
require 'net_tester/command'
require 'net_tester/test_switch'
require 'phut'
require 'phut/shell_runner'
require 'trema'

# Base module
module NetTester
  extend Phut::ShellRunner

  def self.run(dpid, vlan = '')
    controller_file = File.expand_path File.join(__dir__, 'net_tester/controller.rb')
    Trema::Command.new.run([controller_file, dpid, vlan],
                           daemonize: true, logging_level: ::Logger::INFO)
    @@test_switch = TestSwitch.create(dpid: 0xdad1c001)
  end

  def self.connect_switch(device:, port_number:)
    @@test_switch.add_numbered_port port_number, device
  end

  # rubocop:disable ParameterLists
  def self.add_netns(port_number:, name:, ip_address:, mac_address:, netmask:, route:)
    port_name = "port#{port_number}"
    link = Phut::Link.create(name, port_name)
    netns = Phut::Netns.create(name: name,
                               ip_address: ip_address,
                               mac_address: mac_address,
                               netmask: netmask,
                               route: route)
    @@test_switch.add_numbered_port port_number, link.device(port_name)
    netns.device = link.device(name)
    netns
  end
  # rubocop:enable ParameterLists

  def self.create_patch(source_port:, source_mac_address:, destination_port:)
    Trema.trema_process('NetTesterController', Phut.socket_dir).controller
         .create_patch(source_port: source_port,
                       source_mac_address: source_mac_address,
                       destination_port: destination_port)
  end
end
