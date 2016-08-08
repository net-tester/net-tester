# frozen_string_literal: true
require 'active_flow'
require 'faker'
require 'net_tester/test_switch'
require 'phut'
require 'phut/vhost'
require 'phut/link'
require 'phut/setting'
require 'phut/shell_runner'
require 'trema'

module NetTester
  # net_tester sub-commands
  module Command
    extend Phut::ShellRunner

    def self.run(dpid, vlan = '')
      controller_file = File.expand_path File.join(__dir__, 'controller.rb')
      sh "bundle exec trema run #{controller_file} -L #{File.expand_path Phut.log_dir} -P #{File.expand_path Phut.pid_dir} -S #{File.expand_path Phut.socket_dir} --daemon -- #{dpid} #{vlan}"
      @@test_switch = TestSwitch.create(dpid: 0xdad1c001)
    end

    def self.add_host(nhost)
      ip_address = Array.new(nhost) { Faker::Internet.ip_v4_address }
      mac_address = Array.new(nhost) { Faker::Internet.mac_address }
      arp_entries = ip_address.zip(mac_address).map { |each| each.join('/') }.join(',')

      1.upto(nhost).each do |each|
        host_name = "host#{each}"
        port_name = "port#{each}"
        link = Phut::Link.create(host_name, port_name)
        Phut::Vhost.create(name: host_name,
                           ip_address: ip_address[each - 1],
                           mac_address: mac_address[each - 1],
                           device: link.device(host_name),
                           arp_entries: arp_entries)
        @@test_switch.add_numbered_port each, link.device(port_name)
      end
    end

    def self.connect_switch(device:, port_number:)
      @@test_switch.add_numbered_port port_number, device
    end

    # TODO: Raise if vport or port not found
    # TODO: Raise if NetTester is not running
    def self.add(vport, port)
      mac_address = Phut::Vhost.find_by(name: "host#{vport}").mac_address
      Trema.trema_process('NetTesterController', Phut.socket_dir).controller
           .create_patch(source_port: vport,
                         source_mac_address: mac_address,
                         destination_port: port)
    end

    def self.delete(vport, port)
      mac_address = Phut::Vhost.find_by(name: "host#{vport}").mac_address
      Trema.trema_process('NetTesterController', Phut.socket_dir).controller
           .destroy_patch(source_port: vport,
                          source_mac_address: mac_address,
                          destination_port: port)
    end

    def self.list
      Trema.trema_process('NetTesterController', Phut.socket_dir).controller.list_patches
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
      Trema.trema_process('NetTesterController', 'tmp/sockets').controller
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
end
