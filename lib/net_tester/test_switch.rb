# frozen_string_literal: true
require 'phut/switch'

module NetTester
  # NetTester software OpenFlow Switch
  class TestSwitch < Phut::Switch
    name_prefix 'test_'
  end
end
