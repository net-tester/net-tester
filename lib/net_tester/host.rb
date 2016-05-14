# coding: utf-8
# frozen_string_literal: true
require 'net_tester/sh'
require 'phut/vhost'
require 'phut/vhost_daemon'

module NetTester
  # Virtual host for NetTester
  class Host
    include Sh

    attr_reader :name
    attr_reader :ip_address
    attr_reader :mac_address
    attr_reader :device
    attr_reader :arp_entries

    def self.socket_dir
      File.expand_path './tmp/sockets'
    end

    def self.all
      Dir.glob(File.join(socket_dir, 'vhost.*.ctl')).map do |each|
        vhost = DRbObject.new_with_uri("drbunix:#{each}")
        new(name: vhost.name,
            ip_address: vhost.ip_address,
            mac_address: vhost.mac_address,
            device: vhost.device)
      end
    end

    def self.create(*args)
      new(*args).tap(&:start)
    end

    def self.destroy_all(socket_dir:)
      Dir.glob(File.join(socket_dir, 'vhost.*.ctl')).each do |each|
        /vhost\.(\S+)\.ctl/=~ each
        system "vhost stop -n #{Regexp.last_match(1)} -S #{socket_dir}"
      end
    end

    def initialize(name:, ip_address:, mac_address:, device:, arp_entries: nil)
      @name = name
      @ip_address = ip_address
      @mac_address = mac_address
      @device = device
      @arp_entries = arp_entries
    end

    def start
      sh "rvmsudo bundle exec vhost run #{run_options}"
      sleep 1
    end

    def stop
      sh "bundle exec vhost stop -n #{name} -S #{socket_dir}"
      sleep 1
    end

    def send_packet(destination)
      Phut::VhostDaemon.process(name, socket_dir).send_packets(destination.vhost, 1)
    end

    def packets_received_from(source)
      Phut::VhostDaemon.process(name, socket_dir).stats[:rx].select do |each|
        (each[:source_mac].to_s == source.mac_address) && (each[:source_ip_address].to_s == source.ip_address)
      end
    end

    def vhost
      Phut::Vhost.new(ip_address, mac_address, false, name, Phut::NullLogger.new)
    end

    private

    def run_options
      ["-n #{name}",
       "-I #{device}",
       "-i #{ip_address}",
       "-m #{mac_address}",
       arp_entries.nil? ? nil : "-a #{arp_entries}",
       "-L #{log_dir}",
       "-P #{pid_dir}",
       "-S #{socket_dir}"].compact.join(' ')
    end

    def log_dir
      File.expand_path './log'
    end

    def pid_dir
      File.expand_path './tmp/pids'
    end

    def socket_dir
      File.expand_path './tmp/sockets'
    end
  end
end
