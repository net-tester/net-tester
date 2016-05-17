Feature: パッチに VLAN タグを指定
  Background:
    Given テスト対象のネットワークに PacketIn を調べる OpenFlow スイッチを起動
    And NetTester と VLAN を有効にしたテストホスト 2 台を起動:
      | Host | VLAN ID |
      |    1 |     100 |
      |    2 |     200 |
  
  Scenario: 仮想ポートに VLAN ID を指定してパッチを作る
    When 次のパッチを追加:
      | Virtual Port | Physical Port |
      |            1 |             1 |
      |            2 |             2 |
    And 各テストホストから次のようにパケットを送信:
      | Source Host | Destination Host |
      |           1 |                2 |
      |           2 |                1 |
    Then テスト対象の OpenFlow スイッチに次の PacketIn が届く:
      | Port | VLAN ID |
      |    1 |     100 |
      |    2 |     200 |
