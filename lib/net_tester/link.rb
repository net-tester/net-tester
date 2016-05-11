# frozen_string_literal: true
require 'active_support/core_ext/class/attribute_accessors'
require 'phut/null_logger'
require 'phut/virtual_link'

module NetTester
  # Virtual link
  class Link
    cattr_accessor(:all, instance_reader: false) { [] }

    def self.create
      all << new
      all.last
    end

    def self.destroy_all
      all.each(&:stop)
      all.clear
    end

    def initialize
      index = self.class.all.size
      @link = Phut::VirtualLink.new("link#{index}-1", "link#{index}-2", Phut::NullLogger.new)
      @link.run
    end

    def stop
      @link.stop
    end

    def devices
      [@link.device_a, @link.device_b]
    end
  end
end
