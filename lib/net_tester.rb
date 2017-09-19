# frozen_string_literal: true

require 'faker'
require 'net_tester/netns'
require 'net_tester/test_switch'
require 'net_tester/process'
require 'phut'
require 'phut/shell_runner'
require 'trema'

# Base module
module NetTester

  PRIORITY_LOW = 100
  PRIORITY_MID = 200
  PRIORITY_HIGH = 300

  extend Phut::ShellRunner

  @process_dir = '/tmp'

  def self.log_dir
    Phut.log_dir
  end

  def self.log_dir=(dir)
    FileUtils.mkdir_p(dir) unless File.exist?(dir)
    Phut.log_dir = dir
  end

  def self.pid_dir
    Phut.pid_dir
  end

  def self.pid_dir=(dir)
    FileUtils.mkdir_p(dir) unless File.exist?(dir)
    Phut.pid_dir = dir
  end

  def self.socket_dir
    Phut.socket_dir
  end

  def self.socket_dir=(dir)
    FileUtils.mkdir_p(dir) unless File.exist?(dir)
    Phut.socket_dir = dir
  end

  def self.process_dir
    @process_dir
  end

  def self.process_dir=(dir)
    dir = File.expand_path(dir)
    FileUtils.mkdir_p(dir) unless File.exist?(dir)
    @process_dir = dir
  end

  def self.run(network_device:, physical_switch_dpid:)
    controller_file = File.expand_path File.join(__dir__, 'net_tester/controller.rb')
    sh "bundle exec trema -v run #{controller_file} -L #{NetTester.log_dir} -P #{NetTester.pid_dir} -S #{NetTester.socket_dir} --daemon -- #{physical_switch_dpid}"
    @test_switch = TestSwitch.create(dpid: 0xdad1c001)
    connect_device_to_virtual_port(device: network_device, port_number: 1)
  end

  def self.connect_device_to_virtual_port(device:, port_number:)
    @test_switch.add_numbered_port port_number, device
  end

  def self.controller
    Trema.trema_process('NetTesterController', NetTester.socket_dir).controller
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
                         ip_address: ip_address[each - 1], mac_address: mac_address[each - 1],
                         device: link.device(host_name), arp_entries: arp_entries)
      connect_device_to_virtual_port(device: link.device(port_name),
                                     port_number: each + 1)
    end
  end

  # TODO: Raise if vport or port not found
  # TODO: Raise if NetTester is not running
  def self.add(vport, port, vlan_id = nil)
    mac_address = Phut::Vhost.find_by(name: "host#{vport - 1}").mac_address
    vlan_id = vlan_id.nil? ? nil : vlan_id.to_i
    controller.create_patch(source_port: vport,
                            source_mac_address: mac_address,
                            destination_port: port,
                            vlan_id: vlan_id)
  end

  def self.add_p2p(port_a, port_b)
    controller.create_p2p_patch(source_port: port_a, destination_port: port_b)
  end

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
    Trema.trema_process('NetTesterController', NetTester.socket_dir).controller
  rescue
    false
  end

  # TODO: Remove rescue
  def self.kill
    TestSwitch.destroy_all
    Phut::Netns.destroy_all
    Phut::Vhost.destroy_all
    Phut::Link.destroy_all
    Process.destroy_all
  rescue
    true
  ensure
    begin
      Trema.trema_process('NetTesterController', NetTester.socket_dir).killall
    rescue DRb::DRbConnError
      true
    rescue
      # Controller process "NetTesterController" does not exist
      true
    end
  end
end
