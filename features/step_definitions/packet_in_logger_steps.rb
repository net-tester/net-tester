# coding: utf-8
# frozen_string_literal: true

Given(/^PacketIn を調べる OpenFlow スイッチ$/) do
  @testee_switch = TesteeSwitch.create(dpid: 0x1, tcp_port: 6654)
  step %(I successfully run `bundle exec trema run ../../fixtures/packet_in_logger.rb --port 6654 -L #{Phut.log_dir} -P #{Phut.pid_dir} -S #{Phut.socket_dir} --daemon`)
end

Then(/^テスト対象の OpenFlow スイッチのポート (\d+) に PacketIn が届く$/) do |port_number|
  step %(the file "./log/PacketInLogger.log" should contain "PACKET_IN: Port = #{port_number}")
end

Then(/^テスト対象の OpenFlow スイッチの次のポートに PacketIn が届く:$/) do |table|
  table.hashes.each do |each|
    if each['VLAN ID']
      step %(the file "./log/PacketInLogger.log" should contain "PACKET_IN: Port = #{each['Port']}, VLAN ID = #{each['VLAN ID']}")
    else
      step %(the file "./log/PacketInLogger.log" should contain "PACKET_IN: Port = #{each['Port']}")
    end
  end
end

Then(/^テスト対象の OpenFlow スイッチのポート (\d+) には PacketIn が届かない$/) do |port_number|
  step %(the file "./log/PacketInLogger.log" should not contain "PACKET_IN: Port = #{port_number}")
end
