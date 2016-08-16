# coding: utf-8
# frozen_string_literal: true

Given(/^NetTester を起動$/) do
  NetTester.run @physical_test_switch.dpid
  main_link = Phut::Link.create('ssw', 'psw')
  NetTester.connect_switch(device: main_link.device(:ssw), port_number: 1)
  @physical_test_switch.add_numbered_port(1, main_link.device(:psw))
end

When(/^次のパッチを追加:$/) do |table|
  table.hashes.each do |each|
    NetTester.add(each['Virtual Port'].to_i, each['Physical Port'].to_i)
  end
end

When(/^次のパッチを削除:$/) do |table|
  table.hashes.each do |each|
    NetTester.delete(each['Virtual Port'].to_i, each['Physical Port'].to_i)
  end
end

When(/^各テストホストから次のようにパケットを送信:$/) do |table|
  table.hashes.each do |each|
    NetTester.send_packet("host#{each['Source Host']}",
                          "host#{each['Destination Host']}")
  end
  sleep 1
end

Then(/^各テストホストは次のようにパケットを受信する:$/) do |table|
  table.hashes.each do |each|
    packets_received = NetTester.packets_received("host#{each['Destination Host']}", "host#{each['Source Host']}")
    expect(packets_received).to be 1
  end
end
