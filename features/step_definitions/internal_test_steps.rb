# coding: utf-8
# frozen_string_literal: true
Given(/^DPID が (\S+) の NetTester 物理スイッチ$/) do |dpid|
  @physical_test_switch_dpid = dpid.hex
  @physical_test_switch = PhysicalTestSwitch.create(dpid: dpid.hex)
end

Given(/^NetTester でテストホスト (\d+) 台を起動$/) do |nhost|
  raise 'NetTester 物理スイッチが起動していない' unless @physical_test_switch_dpid
  NetTester::Command.run nhost.to_i, @physical_test_switch_dpid
  sleep 1
end

Given(/^NetTester と VLAN を有効にしたテストホスト (\d+) 台を起動:$/) do |nhost, table|
  vlan_option = + table.hashes.map do |each|
    "host#{each['Host']}:#{each['VLAN ID']}"
  end.join(',')
  NetTester::Command.run nhost.to_i, @physical_test_switch_dpid, vlan_option
  sleep 1
end

Given(/^テスト対象のネットワークに PacketIn を調べる OpenFlow スイッチ$/) do
  Switch.create(dpid: 0x1, port: 6654)
  cd('.') do
    step %(I successfully run `bundle exec trema run ../../fixtures/packet_in_logger.rb --port 6654 -L #{log_dir} -P #{pid_dir} -S #{socket_dir} --daemon`)
  end
end

Given(/^テスト対象のネットワークにイーサネットスイッチが 1 台$/) do
  Switch.create(dpid: 0x1, port: 6654)
  cd('.') do
    step %(I successfully run `bundle exec trema run ../../vendor/learning_switch/lib/learning_switch.rb --port 6654 -L #{log_dir} -P #{pid_dir} -S #{socket_dir} --daemon`)
  end
end

Given(/^NetTester 物理スイッチとテスト対象のスイッチを次のように接続:$/) do |table|
  table.hashes.each do |each|
    pport_id = each['Physical Port'].to_i
    tport_id = each['Testee Port'].to_i
    port_name = "pport#{pport_id}"
    tport_name = "tport#{tport_id}"
    link = Link.create(tport_name, port_name)
    @physical_test_switch.add_numbered_port(pport_id, link.device(port_name))
    # FIXME: Switch.find_by(name: testee_switch.name).add_port ...
    Switch.all.first.add_numbered_port tport_id, link.device(tport_name)
  end
end

Given(/^NetTester 仮想スイッチと物理スイッチを次のように接続:$/) do |table|
  # FIXME: リンクは一本だけなので each しない
  table.hashes.each do |each|
    main_link = Link.create('ssw', 'psw')
    NetTester::Command.connect_switch(device: main_link.device(:ssw), port_number: each['Virtual Port'].to_i)
    @physical_test_switch.add_numbered_port(each['Physical Port'].to_i, main_link.device(:psw))
  end
end

Then(/^テスト対象の OpenFlow スイッチの次のポートに PacketIn が届く:$/) do |table|
  table.hashes.each do |each|
    if each['VLAN ID']
      step %(the file "#{File.join log_dir, 'PacketInLogger.log'}" should contain "PACKET_IN: Port = #{each['Port']}, VLAN ID = #{each['VLAN ID']}")
    else
      step %(the file "#{File.join log_dir, 'PacketInLogger.log'}" should contain "PACKET_IN: Port = #{each['Port']}")
    end
  end
end

Then(/^テスト対象の OpenFlow スイッチの次のポートに PacketIn は届かない:$/) do |table|
  table.hashes.each do |each|
    cd('.') do
      expect(IO.readlines("#{log_dir}/PacketInLogger.log").any? { |line| /PACKET_IN #{each['port']}/ =~ line }).to be false
    end
  end
end

Then(/^OpenFlow コントローラが停止$/) do
  step 'the file "tmp/pids/NetTesterController.pid" should not exist'
end

Then(/^すべてのスイッチが停止$/) do
  expect(NetTester::Switch.all).to be_empty
end

Then(/^次の仮想ホストがすべて停止:$/) do |hosts|
  files = hosts.raw.flatten.map { |each| "tmp/pids/vhost.#{each}.pid" }
  expect(files).not_to include be_an_existing_file
end

Then(/^すべてのリンクが停止$/) do
  expect(NetTester::Link.all).to be_empty
end
