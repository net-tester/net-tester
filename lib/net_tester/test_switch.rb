# frozen_string_literal: true
require 'phut'

module NetTester
  # NetTester software OpenFlow Switch
  class TestSwitch < Phut::OpenVswitch
    name_prefix 'test_'
  end
end
