# frozen_string_literal: true
FactoryGirl.define do
  sequence(:mac_address) { |_n| Array.new(6) { '%02x' % rand(0..255) }.join(':') }
end
