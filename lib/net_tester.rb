# frozen_string_literal: true
require 'faker'
require 'net_tester/test_switch'
require 'phut'
require 'phut/shell_runner'
require 'trema'

# Base module
module NetTester
  extend Phut::ShellRunner

  def self.run(dpid, vlan = '')
    controller_file = File.expand_path File.join(__dir__, 'net_tester/controller.rb')
    sh "bundle exec trema run #{controller_file} -L #{Phut.log_dir} -P #{Phut.pid_dir} -S #{Phut.socket_dir} --daemon -- #{dpid} #{vlan}"
    @test_switch = TestSwitch.create(dpid: 0xdad1c001)
  end

  def self.connect_device_to_virtual_port(device:, port_number:)
    @test_switch.add_numbered_port port_number, device
  end

  def self.controller
    Trema.trema_process('NetTesterController', Phut.socket_dir).controller
  end

  def self.patch_netns_to_physical_port(netns:,
                                        physical_port_number:,
                                        virtual_port_number:)
    virtual_port_name = "port#{virtual_port_number}"
    link = Phut::Link.create(netns.name, virtual_port_name)
    connect_device_to_virtual_port(device: link.device(virtual_port_name),
                                   port_number: virtual_port_number)
    controller.create_patch(source_port: virtual_port_number,
                            source_mac_address: netns.mac_address,
                            destination_port: physical_port_number)
    netns.device = link.device(netns.name)
  end

  def self.add_host(nhost)
    ip_address = Array.new(nhost) { Faker::Internet.ip_v4_address }
    mac_address = Array.new(nhost) { Faker::Internet.mac_address }
    arp_entries = ip_address.zip(mac_address).map { |each| each.join('/') }.join(',')

    1.upto(nhost).each do |each|
      host_name = "host#{each}"
      port_name = "port#{each + 1}"
      link = Phut::Link.create(host_name, port_name)
      Phut::Vhost.create(name: host_name,
                         ip_address: ip_address[each - 1],
                         mac_address: mac_address[each - 1],
                         device: link.device(host_name),
                         arp_entries: arp_entries)
      @test_switch.add_numbered_port each + 1, link.device(port_name)
    end
  end

  # TODO: Raise if vport or port not found
  # TODO: Raise if NetTester is not running
  def self.add(vport, port)
    mac_address = Phut::Vhost.find_by(name: "host#{vport - 1}").mac_address
    controller.create_patch(source_port: vport,
                            source_mac_address: mac_address,
                            destination_port: port)
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
    @test_switch.add_numbered_port port_number, link.device(port_name)
    netns.device = link.device(name)
    netns
  end
  # rubocop:enable ParameterLists

  def self.list
    controller.list_patches
  end

  # TODO: Raise if source_name or dest_name not found
  def self.send_packet(source_name, dest_name)
    source = Phut::Vhost.find_by(name: source_name)
    dest = Phut::Vhost.find_by(name: dest_name)
    source.send_packet(dest)
  end

  def self.packets_sent(source_name, dest_name)
    source = Phut::Vhost.find_by(name: source_name)
    dest = Phut::Vhost.find_by(name: dest_name)
    source.packets_sent_to(dest).size
  end

  # TODO: Raise if dest_name or source_name not found
  def self.packets_received(dest_name, source_name)
    dest = Phut::Vhost.find_by(name: dest_name)
    source = Phut::Vhost.find_by(name: source_name)
    dest.packets_received_from(source).size
  end

  def self.running?
    Trema.trema_process('NetTesterController', Phut.socket_dir).controller
  rescue
    false
  end

  def self.kill
    TestSwitch.destroy_all
    Phut::Vhost.destroy_all
    Phut::Link.destroy_all
    # TODO: Remove rescue
    begin
      Trema.trema_process('NetTesterController', Phut.socket_dir).killall
    rescue DRb::DRbConnError
      true
    rescue
      true
    end
  end
end
