# frozen_string_literal: true
require 'net_tester/switch'

module NetTester
  # NetTester physical OpenFlow Switch
  class PhysicalTestSwitch < Switch
    PREFIX = 'psw'
  end
end
