# frozen_string_literal: true
require 'net_tester'
require 'phut'

ENV['GLI_DEBUG'] = 'true'

module NetTester
  # NetTester physical OpenFlow switch
  class PhysicalTestSwitch < Phut::OpenVswitch
    PhysicalTestSwitch.bridge_prefix = 'physw_'
  end

  # Testee physical switch
  class TesteeSwitch < Phut::OpenVswitch
    TesteeSwitch.bridge_prefix = 'testee_'
  end
end

include NetTester
