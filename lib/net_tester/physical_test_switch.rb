# frozen_string_literal: true
require 'phut/switch'

module NetTester
  # NetTester physical OpenFlow Switch
  class PhysicalTestSwitch < Phut::Switch
    PREFIX = 'psw'
  end
end
