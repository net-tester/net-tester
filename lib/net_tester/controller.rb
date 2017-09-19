# frozen_string_literal: true

# FIXME: Delete the following "$LOAD_PATH..." and "require ..." line
$LOAD_PATH.unshift File.join(__dir__, '..')
require 'active_flow'
require 'net_tester/patch'

# Software patch panel controller
class NetTesterController < Trema::Controller
  include NetTester

  # args0: dpid
  def start(args)
    @physical_switch_dpid = args.first.to_i
    logger.info "#{name} started (Physical switch dpid = #{@physical_switch_dpid.to_hex})"
  end

  def switch_ready(dpid)
    logger.info "Switch #{dpid.to_hex} connected"
    @physical_switch_started = true if dpid == @physical_switch_dpid

    # Add default drop rule to each switch
    # to avoid death by parse error of unknown packet/frame.
    send_flow_mod_add(dpid, priority: 0, match: Match.new)

    # TODO: maybe need more precise broadcasting control?
    return unless dpid != 0xdad1001
    send_flow_mod_add(0xdad1c001,
                      priority: 0x1,
                      match: Match.new(in_port: 1,
                                       destination_mac_address: 'ff:ff:ff:ff:ff:ff'),
                      actions: SendOutPort.new(:flood))
  end

  def create_patch(source_port:, source_mac_address:, destination_port:, vlan_id:)
    unless @physical_switch_started
      raise "Physical switch #{@physical_switch_dpid.to_hex} is not yet connected to #{self.class}"
    end
    Patch.create(physical_switch_dpid: @physical_switch_dpid,
                 vlan_id: vlan_id,
                 source_port: source_port,
                 source_mac_address: source_mac_address,
                 destination_port: destination_port)
  end

  def create_p2p_patch(source_port:, destination_port:)
    unless @physical_switch_started
      raise "Physical switch #{@physical_switch_dpid.to_hex} is not yet connected to #{self.class}"
    end
    Patch.create_p2p(physical_switch_dpid: @physical_switch_dpid,
                     source_port: source_port,
                     destination_port: destination_port)
  end

  def destroy_patch(source_port:, source_mac_address:, destination_port:, vlan_id:)
    Patch.destroy(physical_switch_dpid: @physical_switch_dpid,
                  vlan_id: vlan_id,
                  source_port: source_port,
                  source_mac_address: source_mac_address,
                  destination_port: destination_port)
  end

  def list_patches
    Patch.all.map(&:to_s).join("\n")
  end
end
