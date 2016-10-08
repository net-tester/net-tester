Feature: パッチに VLAN タグを指定
  Background:
    Given PacketIn を調べる OpenFlow スイッチ
    And DPID が 0x123 の NetTester 物理スイッチ
    And テストホスト 3 台を起動
    And NetTester 物理スイッチとテスト対象のスイッチを次のように接続:
      | Physical Port | Testee Port |
      |             2 |           1 |
      |             3 |           2 |
      |             4 |           3 |
  Scenario: 仮想ポートに VLAN ID を指定してパッチを作る
    When 次のパッチを追加:
      | Host | Virtual Port | Physical Port | VLAN ID |
      |    1 |            2 |             2 |     100 |
      |    2 |            3 |             3 |     200 |
      |    3 |            4 |             4 |     100 |
    And 各テストホストから次のようにパケットを送信:
      | Source Host | Destination Host |
      |           1 |                2 |
      |           2 |                3 |
      |           3 |                1 |
    Then 各テストホストは以下の数パケットを受信する:
      | Source Host | Destination Host | Received Packets |
      |           1 |                2 |                0 |
      |           2 |                3 |                0 |
      |           3 |                1 |                2 |
    Then テスト対象の OpenFlow スイッチの次のポートに PacketIn が届く:
      | Port | VLAN ID |
      |    1 |     100 |
      |    2 |     200 |
      |    3 |     100 |
