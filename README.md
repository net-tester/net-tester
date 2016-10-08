# NetTesterとは

NetTesterは物理ネットワークのための受け入れテストツールです。物理ネットワークに仮想的なホストをつなぎ込み、ping疎通などのテストをソフトウェアで自動実行できます。仮想ホストの生成と物理ネットワークへのつなぎ込みをすべてソフトウェア的に行うため、人手では時間のかかる網羅的なテストもスクリプトによって自動的に実行できます。

![overview](https://raw.githubusercontent.com/net-tester/net-tester/develop/img/overview.png)

NetTesterでのテストはテストスクリプトに沿って実行します。テストスクリプトには次の要素を記述できます:

* 仮想ホストと物理ネットワークの接続関係
* 「host1 から host2 への ping が通る」といった一連のテスト項目

NetTesterテストスクリプトを実行すると、仮想ホストが物理ネットワークに接続し、パケットを送受信した結果を表示します。テストツールとしては現在 [Cucumber](https://cucumber.io) をサポートしています。

## NetTester の仕組み

NetTesterの最小構成は、LinuxマシンとOpenFlow物理スイッチのみです。

![network](https://raw.githubusercontent.com/net-tester/net-tester/develop/img/network.png)

Linuxマシンはパケットを送受信する仮想ホストとソフトウェアOpenFlowスイッチを起動します。OpenFlow物理スイッチは仮想OpenFlowスイッチとの間に仮想パッチを作ることで、仮想ホストを物理ネットワークに仮想的に接続します。このように、Linuxマシン一台と物理OpenFlowスイッチを用意すれば、NetTesterを使ってさまざまなパターンのテストを自動的に実行できます。

# インストール

インストールには次のものが必要です:

* Ruby 2.2.0 以上
* [Open vSwitch](https://openvswitch.org/) (`apt-get install openvswitch-switch`).

``` shellsession
$ git clone https://github.com/net-tester/net-tester.git
$ cd net_tester
$ bundle install
```

# コマンド一覧

## net_tester run [オプション]
NetTester を起動する

```shellsession
$ ./bin/net_tester run --nhost 3 --device eth1 --dpid 0x123
```

* --nhost: 起動する仮想ホストの台数
* --device: 仮想スイッチが使うデバイス名
* --dpid: 物理スイッチの DPID

![network](https://raw.githubusercontent.com/net-tester/net-tester/develop/img/run_example.png)

## net_tester add [オプション]
パッチを追加する

```shellsession
$ ./bin/net_tester add --vport 2 --port 1 --vlan 100
```

* --vport: 仮想スイッチのポート番号
* --port: 物理スイッチのポート番号
* --vlan: 物理スイッチのポートからパケットに付く VLAN ID

![network](https://raw.githubusercontent.com/net-tester/net-tester/develop/img/add_example.png)

## net_tester delete [オプション]
パッチを削除する

```shellsession
$ ./bin/net_tester delete --vport 2 --port 1
```

* --vport: 仮想スイッチのポート番号
* --port: 物理スイッチのポート番号

## net_tester send [オプション]
パケットを送信する

```shellsession
$ net_tester send --source host1 --dest host2
```

* --source: 送信元ホスト名
* --dest: 宛先ホスト名

## net_tester stats ホスト名
指定したホストの送受信パケット数を表示

```shellsession
$ ./bin/net_tester stats host1
Packets sent:
  host1 -> host2 = 1 packet
Packets received:
  host2 -> host1 = 1 packet
```

## net_tester kill
NetTester を停止する

# テストシナリオの書き方

## テスト構成例

![test_scenario](https://raw.githubusercontent.com/net-tester/net-tester/develop/img/test_scenario.png)

## Cucumber シナリオ

```cucumber
Feature: ポート 1 とポート 2 でパケットを送受信

  ネットワークのポート 1 番とポート 2 番に接続したホスト同士で
  パケットを送受信できる

  Scenario: ポート 1 番とポート 2 番でパケットを送受信
    Given NetTester をオプション "--nhost 2 --device eth1 --dpid 0x123" で起動
    When 次のパッチを追加:
      | Virtual Port | Physical Port |
      |            1 |             1 |
      |            2 |             2 |
    And 各テストホストから次のようにパケットを送信:
      | Source Host | Destination Host |
      |           1 |                2 |
      |           2 |                1 |
    Then 各テストホストは次のようにパケットを受信する:
      | Source Host | Destination Host |
      |           1 |                2 |
      |           2 |                1 |
```

### Setup & Teardown

features/support/hooks.rb:

```ruby
require 'net_tester'
require 'active_support/core_ext/object/try'

Before do
  NetTester.log_dir = File.join(Aruba.config.working_directory, 'log')
  NetTester.pid_dir = File.join(Aruba.config.working_directory, 'pids')
  NetTester.socket_dir = File.join(Aruba.config.working_directory, 'sockets')

  device = ENV['DEVICE'] || 'eth1'
  dpid = ENV['DPID'].try(&:hex) || 0x123
  NetTester.run(network_device: device, physical_switch_dpid: dpid)
end

After do
  NetTester.kill
end
```

# 関連ツール

NetTester は次のソフトウェアを参考にしました。感謝!

* [stereocat/patch_panel](https://github.com/stereocat/patch_panel): [Trema](https://github.com/trema/trema) で構築した物理ネットワークテストツールです
* [oolorg/ool-l1patch-dev](https://github.com/oolorg/ool-l1patch-dev): [Ryu](https://osrg.github.io/ryu/) で構築した物理ネットワークテストツールです
