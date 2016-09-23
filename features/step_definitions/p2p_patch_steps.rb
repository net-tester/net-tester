# coding: utf-8
# frozen_string_literal: true
Given(/^NetTester 物理スイッチとテスト対象ホストを次のように接続:$/) do |table|
  ip_of_host = {}
  mac_of_host = {}
  vhost_arp_list = []

  table.hashes.each do |each|
    host_id = each['Host']
    ip_address = "192.168.0.#{host_id}"
    ip_of_host[host_id] = ip_address
    mac_address = "00:ba:dc:ab:1e:#{format('%02x', host_id)}"
    mac_of_host[host_id] = mac_address
    vhost_arp_list.append "#{ip_address}/#{mac_address}"
  end

  arp_entries = vhost_arp_list.join(',')
  table.hashes.each do |each|
    pport_id = each['Physical Port'].to_i
    pport_name = "pport#{pport_id}"
    host_id = each['Host']
    host_name = "host#{host_id}"
    link = Phut::Link.create(host_name, pport_name)
    Phut::Vhost.create(name: host_name,
                       ip_address: ip_of_host[host_id],
                       mac_address: mac_of_host[host_id],
                       device: link.device(host_name),
                       arp_entries: arp_entries)
    @physical_test_switch.add_numbered_port(pport_id, link.device(pport_name))
  end
end

When(/^次のNW機器間パッチを追加:$/) do |table|
  table.hashes.each do |each|
    pport_a = each['Physical Port A'].to_i
    pport_b = each['Physical Port B'].to_i
    NetTester.add_p2p(pport_a, pport_b)
  end
end
