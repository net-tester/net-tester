# frozen_string_literal: true
require 'pio'
require 'trema/controller'

module ActiveFlow
  # Base class of flow entries
  class Base
    # OpenFlow1.0 FlowMod options
    class FlowModAddOption
      def initialize(user_options)
        @user_options = user_options
      end

      def to_hash
        {
          command: :add,
          priority: @user_options[:priority] || 0,
          transaction_id: rand(0xffffffff),
          idle_timeout: @user_options[:idle_timeout] || 0,
          hard_timeout: @user_options[:hard_timeout] || 0,
          buffer_id: @user_options[:buffer_id] || 0xffffffff,
          match: @user_options.fetch(:match),
          actions: @user_options[:actions] || []
        }
      end
    end

    include Pio::OpenFlow10
    include NetTester

    def self.send_flow_mod_add(datapath_id, options)
      send_message datapath_id, FlowMod.new(FlowModAddOption.new(options).to_hash)
    end

    def self.send_message(datapath_id, message)
      Trema::Controller::SWITCH.fetch(datapath_id).write message
    end

    def self.flow_stats_reply(datapath_id, message)
      @@flow_stats_reply[datapath_id] = message
    end

    def self.flow_stats(dpid)
      @@flow_stats_reply ||= {}
      @@flow_stats_reply[dpid] = nil
      send_message dpid, FlowStats::Request.new
      sleep 1 # FIXME
      @@flow_stats_reply[dpid]
    end
  end
end
