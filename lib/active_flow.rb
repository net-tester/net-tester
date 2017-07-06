# frozen_string_literal: true
require 'active_flow/base'
require 'phut/vhost'
require 'net_tester'

$LOAD_PATH.unshift File.join(__dir__, '..')

Dir.glob(File.join(__dir__, '..', 'app', 'flows', '*.rb')).each do |each|
  require each.gsub(/\.rb$/, '')
end
