# coding: utf-8
# frozen_string_literal: true

Given(/^DPID が (\S+) の NetTester 物理スイッチ$/) do |dpid|
  @physical_test_switch = PhysicalTestSwitch.create(dpid: dpid.hex)
  NetTester.run dpid.hex
  main_link = Phut::Link.create('ssw', 'psw')
  NetTester.connect_switch(device: main_link.device(:ssw), port_number: 1)
  @physical_test_switch.add_numbered_port(1, main_link.device(:psw))
end

Given(/^テストホスト (\d+) 台$/) do |nhost|
  raise 'NetTester 物理スイッチが起動していない' unless @physical_test_switch
  NetTester.add_host nhost.to_i
  sleep 1
end

Given(/^NetTester 物理スイッチとテスト対象のスイッチを次のように接続:$/) do |table|
  table.hashes.each do |each|
    pport_id = each['Physical Port'].to_i
    tport_id = each['Testee Port'].to_i
    port_name = "pport#{pport_id}"
    tport_name = "tport#{tport_id}"
    link = Phut::Link.create(tport_name, port_name)
    @physical_test_switch.add_numbered_port(pport_id, link.device(port_name))
    @testee_switch.add_numbered_port(tport_id, link.device(tport_name))
  end
end
