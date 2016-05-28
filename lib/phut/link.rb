# frozen_string_literal: true
require 'phut/sh'
require 'phut/virtual_link'

module Phut
  # Virtual link
  class Link
    LINK_DEVICE_PREFIX = 'lnk'

    extend Sh

    def self.all
      link = Hash.new { [] }
      devices.each do |each|
        /^#{LINK_DEVICE_PREFIX}(\d+)_(\S+)/ =~ each
        link[Regexp.last_match(1).to_i] += [Regexp.last_match(2)]
      end
      link.map { |link_id, names| new(*names, link_id: link_id) }
    end

    def self.devices
      sh('LANG=C ifconfig -a').split("\n").map do |each|
        /^(#{LINK_DEVICE_PREFIX}\d+_\S+)/ =~ each ? Regexp.last_match(1) : nil
      end.compact
    end

    def self.create(name_a, name_b)
      new(name_a, name_b).start
    end

    def self.destroy_all
      all.each(&:destroy)
    end

    def initialize(name_a, name_b, link_id: Link.all.size)
      @link = VirtualLink.new(device_name(link_id, name_a),
                              device_name(link_id, name_b))
      @device = [name_a, name_b].each_with_object({}) do |each, hash|
        hash[each.to_sym] = device_name(link_id, each)
      end
    end

    def device(name)
      @device[name.to_sym]
    end

    def start
      @link.run
      self
    end

    def destroy
      @link.stop
    end

    private

    def device_name(link_id, name)
      "#{LINK_DEVICE_PREFIX}#{link_id}_#{name}"
    end
  end
end
