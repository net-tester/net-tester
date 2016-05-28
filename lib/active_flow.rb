# frozen_string_literal: true
require 'active_flow/base'
require 'phut/host'

$LOAD_PATH.unshift File.join(__dir__, '..')

Dir.glob(File.join(__dir__, '..', 'app', 'flows', '*.rb')).each do |each|
  require each.gsub(/\.rb$/, '')
end
