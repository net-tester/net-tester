# NetTesterとは

NetTesterは物理ネットワークのための受け入れテストツールです。物理ネットワークに仮想的なホストをつなぎこみ、ping疎通などのテストをソフトウェア的に実行できます。

![overview](https://raw.githubusercontent.com/yasuhito/net_tester/develop/img/overview.png)

NetTesterでのテストはテストスクリプトに沿って実行します。テストスクリプトには「host1 から host2 への ping が通る」といった一連のテスト項目を記述します。テストスクリプトをNetTesterで実行すると、仮想ホストがテストスクリプトに沿ってパケットを送受信し、実行結果を表示します。テストツールとしては現在 [Cucumber](https://cucumber.io) をサポートしています。

![network](https://raw.githubusercontent.com/yasuhito/net_tester/develop/img/network.png)

NetTesterの最小構成は、LinuxマシンとOpenFlow物理スイッチのみです。Linuxマシン内はパケットを送受信する仮想ホストとソフトウェアOpenFlowスイッチを起動します。OpenFlow物理スイッチは仮想OpenFlowスイッチとの間に仮想パッチを作ることで、仮想ホストをテスト対象ネットワークに仮想的に接続します。このように、NetTester用のNICを持つLinuxマシン一台と物理OpenFlowスイッチを用意すれば、すぐにNetTesterを使い始められます。


# テストシナリオの書き方

## テスト構成例

![test_scenario](https://raw.githubusercontent.com/yasuhito/net_tester/develop/img/test_scenario.png)

## Cucumber シナリオ

```cucumber
Feature: ポート 1 とポート 2 でパケットを送受信

  ネットワークのポート 1 番とポート 2 番に接続したホスト同士で
  パケットを送受信できる

  Scenario: ポート 1 番とポート 2 番でパケットを送受信
    Given DPID が 0xdef の NetTester 物理スイッチ
    And NetTester でテストホスト 2 台を起動
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

### Teardown

```ruby
# features/support/hooks.rb
After do
  NetTester::Command.kill
end
```


# コマンド一覧

## net_tester run [オプション]
NetTester を起動する

```shellsession
$ ./bin/net_tester run --nhost 3 --device eth0 --vlan host1:100,host3:200
```

* --nhost: 起動する仮想ホストの台数
* --device: 仮想スイッチが使うデバイス名
* --vlan: 仮想ホストからのパケットに付ける VLAN ID

![network](https://raw.githubusercontent.com/yasuhito/net_tester/develop/img/run_example.png)

## net_tester add [オプション]
パッチを追加する

```shellsession
$ ./bin/net_tester add --vport 2 --port 1
```

* --vport: 仮想スイッチのポート番号
* --port: 物理スイッチのポート番号

![network](https://raw.githubusercontent.com/yasuhito/net_tester/develop/img/add_example.png)

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
