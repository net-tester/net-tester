Feature: パッチング
  Background:
    Given NetTester とテストホスト 2 台を起動
    And テスト対象のネットワークに PacketIn を調べる OpenFlow スイッチ
    And DPID が 0xdef の NetTester 物理スイッチ
    And NetTester 物理スイッチとテスト対象のスイッチを次のように接続:
      | Physical Port | Testee Port |
      |             1 |           1 |
      |             2 |           2 |
    And NetTester 仮想スイッチと物理スイッチを次のように接続:
      | Virtual Port | Physical Port |
      |            3 |             3 |

  Scenario: パッチを設定する
    When 次のパッチを追加:
      | Virtual Port | Physical Port |
      |            1 |             1 |
      |            2 |             2 |
    And 各テストホストから次のようにパケットを送信:
      | Source Host | Destination Host |
      |           1 |                2 |
      |           2 |                1 |
    Then テスト対象の OpenFlow スイッチの次のポートに PacketIn が届く:
      | Port |
      |    1 |
      |    2 |

  Scenario: あえて変なパッチを設定
    When 次のパッチを追加:
      | Virtual Port | Physical Port |
      |            1 |             1 |
      |            2 |             1 |
    And 各テストホストから次のようにパケットを送信:
      | Source Host | Destination Host |
      |           1 |                2 |
      |           2 |                1 |
    Then テスト対象の OpenFlow スイッチの次のポートに PacketIn が届く:
      | Port |
      |    1 |
    And テスト対象の OpenFlow スイッチの次のポートに PacketIn は届かない:
      | Port |
      |    2 |
