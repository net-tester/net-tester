Feature: パッチング
  Background:
    Given テスト対象のネットワークに PacketIn を調べる OpenFlow スイッチを起動
    And NetTester とテストホスト 2 台を起動

  Scenario: パッチを設定する
    When 次のパッチを追加:
      | virtual port | physical port |
      |            1 |             1 |
      |            2 |             2 |
    And 各テストホストから次のようにパケットを送信:
      | source host | destination host |
      |           1 |                2 |
      |           2 |                1 |
    Then テスト対象の OpenFlow スイッチの次のポートに PacketIn が届く:
      | port |
      |    1 |
      |    2 |

  Scenario: あえて変なパッチを設定
    When 次のパッチを追加:
      | virtual port | physical port |
      |            1 |             1 |
      |            2 |             1 |
    And 各テストホストから次のようにパケットを送信:
      | source host | destination host |
      |           1 |                2 |
      |           2 |                1 |
    Then テスト対象の OpenFlow スイッチの次のポートに PacketIn が届く:
      | port |
      |    1 |
    And テスト対象の OpenFlow スイッチの次のポートには PacketIn が届かない:
      | port |
      |    2 |
