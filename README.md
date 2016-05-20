# NetTesterとは

NetTesterは物理ネットワークのための受け入れテストツールです。物理ネットワークに仮想的なホストをつなぎこみ、ping疎通確認など任意のテストをソフトウェア的に実行できます。

![overview](https://raw.githubusercontent.com/yasuhito/net_tester/develop/img/overview.png)

NetTesterでのテストはテストシナリオに沿って実行します。テストシナリオでは、「host1 から host2 への ping が通る」といった一連のアサーションをスクリプトとして記述します。テストシナリオをNetTesterで実行すると、仮想ホストがシナリオに沿ってパケットを送受信します。

![network](https://raw.githubusercontent.com/yasuhito/net_tester/develop/img/network.png)

NetTesterの最小構成は、一台のLinuxマシンと物理スイッチからなります。Linuxマシン内ではパケットを送受信する仮想ホストを任意の台数だけ起動できます。物理スイッチはOpenFlowスイッチで、仮想ホストをテスト対象ネットワークに接続します。仮想ホストを起動するLinuxマシンにはNICはひとつしか必要ありません。このように、Linuxマシン一台と物理OpenFlowスイッチを用意すれば、すぐにNetTesterを使い始められます。


# テストシナリオの書き方

(そのうち書く。まずは ool-l1patch のシナリオを RSpec に移植)


# コマンド一覧

## net_tester run [オプション]

* --nhost: 起動する仮想ホストの台数
* --device: 仮想スイッチが使うデバイス名

```shellsession
./bin/net_tester run --nhost 3 --device eth0
```

![network](https://raw.githubusercontent.com/yasuhito/net_tester/develop/img/run_example.png)

## net_tester add [オプション]
パッチを追加する

* --vport: 仮想スイッチのポート番号
* --port: 物理スイッチのポート番号

## net_tester send_packet [オプション]
パケットを送信する

* --source: 送信元ホスト名
* --dest: 宛先ホスト名

## net_tester received_packets [オプション]
受信パケット数を表示

* --source: 送信元ホスト名
* --dest: 宛先ホスト名
