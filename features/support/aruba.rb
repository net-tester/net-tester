# frozen_string_literal: true
require 'aruba/cucumber'

Aruba.configure do |config|
  config.startup_wait_time = 20
end
