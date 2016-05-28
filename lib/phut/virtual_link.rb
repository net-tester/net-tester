# frozen_string_literal: true
require 'phut/shell_runner'

module Phut
  # Network virtual link.
  class VirtualLink
    include ShellRunner

    attr_reader :device_a
    attr_reader :device_b

    def initialize(device_a, device_b)
      raise if device_a == device_b
      @device_a = device_a
      @device_b = device_b
    end

    def ==(other)
      @device_a == other.device_a && @device_b == other.device_b
    end

    def run
      stop if up?
      add
      up
    end

    def stop
      return unless up?
      stop!
    end

    def stop!
      sh "sudo ip link delete #{@device_a}"
    rescue
      raise "link #{@device_a} #{@device_b} does not exist!"
    end

    def up?
      /^#{@device_a}\s+Link encap:Ethernet/ =~ `LANG=C ifconfig -a` || false
    end

    private

    def add
      sh "sudo ip link add name #{@device_a} type veth peer name #{@device_b}"
      sh "sudo /sbin/sysctl -q -w net.ipv6.conf.#{@device_a}.disable_ipv6=1"
      sh "sudo /sbin/sysctl -q -w net.ipv6.conf.#{@device_b}.disable_ipv6=1"
    end

    def up
      sh "sudo /sbin/ifconfig #{@device_a} up"
      sh "sudo /sbin/ifconfig #{@device_b} up"
    end
  end
end
