# frozen_string_literal: true
require 'phut/null_logger'
require 'phut/virtual_link'
require 'net_tester/sh'

module NetTester
  # Virtual link
  class Link
    extend Sh

    def self.all
      sh('ifconfig -a').split("\n").select { |each| /^link\d+-1/=~ each }.map do |each|
        /^link(\d+)-1/=~ each
        new(index: Regexp.last_match(1).to_i)
      end
    end

    def self.create
      new.start
    end

    def self.destroy_all
      all.each(&:destroy)
    end

    def initialize(index: Link.all.size)
      @link = Phut::VirtualLink.new("link#{index}-1", "link#{index}-2", Phut::NullLogger.new)
    end

    def start
      @link.run
      self
    end

    def destroy
      @link.stop
    end

    def devices
      [@link.device_a, @link.device_b]
    end
  end
end
