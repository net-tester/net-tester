# frozen_string_literal: true

FactoryGirl.define do
  sequence(:mac_address) do
    Array.new(6) { format '%02x', rand(0..255) }.join(':')
  end
end
