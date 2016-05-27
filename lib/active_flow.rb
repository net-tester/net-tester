# frozen_string_literal: true
require 'net_tester/host'
require 'active_flow/base'

$LOAD_PATH.unshift File.join(__dir__, '..')

Dir.glob(File.join(__dir__, '..', 'app', 'flows', '*.rb')).each do |each|
  require each.gsub(/\.rb$/, '')
end
