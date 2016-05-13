# coding: utf-8
# frozen_string_literal: true
Given(/^テスト対象のネットワークにイーサネットスイッチが 1 台$/) do
  Switch.create(dpid: 0x1, port: 6654)
  system('bundle exec trema run ./vendor/learning_switch/lib/learning_switch.rb --port 6654 -L log --daemon') || raise('Failed to start LearningSwitch')
end

Given(/^テスト用の仮想ホストが (\d+) 台$/) do |nhost|
  @nhost = nhost.to_i
  nhost.to_i.times do
    host = Host.create(ip_address: Faker::Internet.ip_v4_address,
                       mac_address: FactoryGirl.generate(:mac_address))
    link = Link.create
    host.network_device = link.devices.first
    TestSwitch.add_port(link.devices.second)
  end
end

Given(/^NetTester を起動$/) do
  @nhost.times do
    link = Link.create
    PhysicalTestSwitch.add_port(link.devices.first)
    Switch.all.first.add_port link.devices.second
  end

  system("bundle exec trema run ./lib/net_tester/controller.rb -L log --daemon -- #{@nhost}") || raise('Failed to start NetTester')
  link = Link.create
  TestSwitch.add_port(link.devices.first)
  PhysicalTestSwitch.add_port(link.devices.second)
  Switch.all.each(&:start)
  TestSwitch.start
  PhysicalTestSwitch.start
  Host.all.each(&:start)
end

When(/^各テスト用ホストが次のようにパケットを送信:$/) do |table|
  table.hashes.each do |each|
    source_id = each['source host'].to_i - 1
    dest_id = each['destination host'].to_i - 1
    Host.all[source_id].send_packet(Host.all[dest_id])
  end
  sleep 1
end

Then(/^各テスト用ホストは次のようにパケットを受信する:$/) do |table|
  table.hashes.each do |each|
    source = Host.all[each['source host'].to_i - 1]
    dest = Host.all[each['destination host'].to_i - 1]
    expect(dest.packets_received_from(source).size).to eq 1
  end
end
