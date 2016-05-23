Feature: パッチング
  Background:
    Given テスト対象のネットワークに PacketIn を調べる OpenFlow スイッチ
    And DPID が 0xdef のテスト用物理スイッチ
    And テスト対象のスイッチとテスト用物理スイッチをリンク 2 本で接続
    And NetTester とテストホスト 2 台を起動
    And NetTester サーバとテスト用物理スイッチをリンクで接続

  Scenario: パッチを設定する
    When 次のパッチを追加:
      | Virtual Port | Physical Port |
      |            1 |             1 |
      |            2 |             2 |
    And 各テストホストから次のようにパケットを送信:
      | Source Host | Destination Host |
      |           1 |                2 |
      |           2 |                1 |
    Then テスト対象の OpenFlow スイッチに次の PacketIn が届く:
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
    Then テスト対象の OpenFlow スイッチに次の PacketIn が届く:
      | Port |
      |    1 |
    And テスト対象の OpenFlow スイッチに次の PacketIn は届かない:
      | Port |
      |    2 |
