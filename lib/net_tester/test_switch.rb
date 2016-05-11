# frozen_string_literal: true
require 'active_support/core_ext/class/attribute_accessors'
require 'net_tester/switch'

module NetTester
  # NetTester software OpenFlow Switch
  class TestSwitch
    cattr_accessor(:switch, instance_reader: false) { Switch.new(dpid: 0xabc) }

    def self.destroy
      switch.stop
    end

    def self.method_missing(method, *args)
      switch.__send__(method, *args)
    end
  end
end
