Feature: パッチング
  Background:
    Given PacketIn を調べる OpenFlow スイッチ
    And DPID が 0x123 の NetTester 物理スイッチ
    And NetTester を起動
    And テストホスト 2 台
    And NetTester 物理スイッチとテスト対象のスイッチを次のように接続:
      | Physical Port | Testee Port |
      |             2 |           1 |
      |             3 |           2 |

  Scenario: パッチを設定する
    When 次のパッチを追加:
      | Virtual Port | Physical Port |
      |            2 |             2 |
      |            3 |             3 |
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
      |            2 |             2 |
      |            3 |             2 |
    And 各テストホストから次のようにパケットを送信:
      | Source Host | Destination Host |
      |           1 |                2 |
      |           2 |                1 |
    Then テスト対象の OpenFlow スイッチのポート 1 に PacketIn が届く
    And テスト対象の OpenFlow スイッチのポート 2 には PacketIn が届かない
