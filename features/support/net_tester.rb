# frozen_string_literal: true
require 'net_tester'
require 'phut'

module NetTester
  # NetTester physical OpenFlow switch
  class PhysicalTestSwitch < Phut::Switch
    name_prefix 'physw_'
  end

  # Testee physical switch
  class TesteeSwitch < Phut::Switch
    name_prefix 'testee_'
  end
end

include NetTester
include NetTester::Dir
