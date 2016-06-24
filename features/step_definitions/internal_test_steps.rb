# coding: utf-8
# frozen_string_literal: true
Given(/^NetTester を DPID = "([^"]*)" で起動$/) do |dpid|
  @nettester_virtual_switch = NetTester::Command.run(dpid.hex)
end

Given(/^NetTester 物理スイッチ \(DPID = "([^"]*)"\)$/) do |dpid|
  @physical_test_switch_dpid = dpid.hex
  @physical_test_switch = PhysicalTestSwitch.create(dpid: dpid.hex)
  main_link = Phut::Link.create('ssw', 'psw')
  NetTester::Command.connect_switch(device: main_link.device(:ssw), port_number: 1)
  @physical_test_switch.add_numbered_port(1, main_link.device(:psw))
end

Given(/^NetTester のホスト (\d+) 台を起動$/) do |nhost|
  ip_address = Array.new(nhost.to_i) { Faker::Internet.ip_v4_address }
  mac_address = Array.new(nhost.to_i) { Faker::Internet.mac_address }
  arp_entries = ip_address.zip(mac_address).map { |each| each.join('/') }.join(',')
  1.upto(nhost.to_i).each do |each|
    NetTester::Command.add_host(host_name: "host#{each}",
                                ip_address: ip_address[each - 1],
                                mac_address: mac_address[each - 1],
                                arp_entries: arp_entries)
  end
end

Given(/^NetTester と VLAN を有効にしたテストホスト (\d+) 台を起動:$/) do |nhost, table|
  vlan_option = + table.hashes.map do |each|
    "host#{each['Host']}:#{each['VLAN ID']}"
  end.join(',')
  NetTester::Command.run nhost.to_i, @physical_test_switch_dpid, vlan_option
  sleep 1
end

Given(/^テスト対象のネットワークに PacketIn を調べる OpenFlow スイッチ$/) do
  @testee = TesteeSwitch.create(dpid: 0x1, tcp_port: 6654)
  cd('.') do
    step %(I successfully run `bundle exec trema run ../../fixtures/packet_in_logger.rb --port 6654 -L #{Phut.log_dir} -P #{Phut.pid_dir} -S #{Phut.socket_dir} --daemon`)
  end
end

Given(/^テスト対象のネットワークにイーサネットスイッチが 1 台$/) do
  @testee = TesteeSwitch.create(dpid: 0x1, tcp_port: 6654)
  cd('.') do
    step %(I successfully run `bundle exec trema run ../../vendor/learning_switch/lib/learning_switch.rb --port 6654 -L #{Phut.log_dir} -P #{Phut.pid_dir} -S #{Phut.socket_dir} --daemon`)
  end
end

Given(/^NetTester 物理スイッチとテスト対象のスイッチを次のように接続:$/) do |table|
  table.hashes.each do |each|
    pport_id = each['Physical Port'].to_i
    tport_id = each['Testee Port'].to_i
    port_name = "pport#{pport_id}"
    tport_name = "tport#{tport_id}"
    link = Phut::Link.create(tport_name, port_name)
    @physical_test_switch.add_numbered_port(pport_id, link.device(port_name))
    @testee.add_numbered_port tport_id, link.device(tport_name)
  end
end

Given(/^NetTester 仮想スイッチと物理スイッチを次のように接続:$/) do |table|
  # FIXME: リンクは一本だけなので each しない
  table.hashes.each do |each|
    main_link = Phut::Link.create('ssw', 'psw')
    NetTester::Command.connect_switch(device: main_link.device(:ssw),
                                      port_number: each['Virtual Port'].to_i)
    @physical_test_switch.add_numbered_port(each['Physical Port'].to_i,
                                            main_link.device(:psw))
  end
end

Given(/^NetTester のホストと仮想スイッチを次のように接続:$/) do |table|
  @mac_address = {}
  table.hashes.each do |each|
    port_name = "port_#{each['Hostname']}"
    link = Phut::Link.create(each['Hostname'], port_name)
    NetTester::Command.connect_switch(device: link.device(port_name),
                                      port_number: each['Virtual Port'].to_i)
    @netns.fetch(each['Hostname']).device = link.device(each['Hostname'])
    @mac_address[each['Virtual Port'].to_i] = @netns.fetch(each['Hostname']).mac_address
  end

  # FIXME
  system "sudo ip netns exec client arp -s 192.168.0.100 #{@netns['server'].mac_address}"
  system "sudo ip netns exec server arp -s 192.168.0.1 #{@netns['client'].mac_address}"
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

Then(/^テスト対象の OpenFlow スイッチの次のポートに PacketIn は届かない:$/) do |table|
  table.hashes.each do |each|
    cd('.') do
      expect(IO.readlines('./log/PacketInLogger.log').any? do |line|
               /PACKET_IN #{each['port']}/ =~ line
             end).to be false
    end
  end
end

Then(/^OpenFlow コントローラが停止$/) do
  step 'the file "tmp/pids/NetTesterController.pid" should not exist'
end

Then(/^すべてのスイッチが停止$/) do
  expect(TesteeSwitch.all).to be_empty
end

Then(/^次の仮想ホストがすべて停止:$/) do |hosts|
  files = hosts.raw.flatten.map { |each| "tmp/pids/vhost.#{each}.pid" }
  expect(files).not_to include be_an_existing_file
end

Then(/^すべてのリンクが停止$/) do
  expect(Phut::Link.all).to be_empty
end
