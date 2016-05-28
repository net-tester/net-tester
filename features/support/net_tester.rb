# frozen_string_literal: true
require 'net_tester'
require 'phut/switch'

module NetTester
  # NetTester physical OpenFlow Switch
  class PhysicalTestSwitch < Phut::Switch
    name_prefix 'physw_'
  end
end

include NetTester
include NetTester::Dir
