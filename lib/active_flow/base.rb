# frozen_string_literal: true
require 'pio'

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
    rescue KeyError, Errno::ECONNRESET, Errno::EPIPE
      logger.debug "Switch #{datapath_id} is disconnected."
    end
  end
end
