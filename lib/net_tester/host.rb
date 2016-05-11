# frozen_string_literal: true
require 'active_support/core_ext/class/attribute_accessors'
require 'phut/vhost'
require 'phut/vhost_daemon'

module NetTester
  # Virtual host for NetTester
  class Host
    cattr_accessor(:all, instance_reader: false) { [] }

    attr_reader :ip_address
    attr_reader :mac_address
    attr_accessor :network_device

    def self.create(*args)
      all << new(*args)
      all.last
    end

    def self.destroy_all
      @@all.each(&:stop)
      all.clear
    end

    def initialize(ip_address:, mac_address:)
      @ip_address = ip_address
      @mac_address = mac_address
    end

    def start
      sh "rvmsudo vhost run #{run_options}"
    end

    def stop
      sh "vhost stop -n #{ip_address}"
    end

    def send_packet(destination)
      Phut::VhostDaemon.process(ip_address, '/tmp').send_packets(destination.vhost, 1)
    end

    def packets_received_from(source)
      Phut::VhostDaemon.process(ip_address, '/tmp').stats[:rx].select do |each|
        (each[:source_mac].to_s == source.mac_address) && (each[:source_ip_address].to_s == source.ip_address)
      end
    end

    def vhost
      Phut::Vhost.new(ip_address, mac_address, false, ip_address, Phut::NullLogger.new)
    end

    private

    def run_options
      ["-n #{ip_address}",
       "-I #{network_device}",
       "-i #{ip_address}",
       "-m #{mac_address}",
       "-a #{arp_entries}"].compact.join(' ')
    end

    def arp_entries
      Host.all.map do |each|
        "#{each.ip_address}/#{each.mac_address}"
      end.join(',')
    end

    def sh(command)
      system(command) || raise("#{command} failed.")
    end
  end
end
