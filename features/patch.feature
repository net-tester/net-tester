Feature: パッチング
  Background:
    Given テスト対象のネットワークに PacketIn を調べる OpenFlow スイッチを起動
    And テスト用の仮想ホストが 2 台
    And NetTester を起動

  Scenario: パッチを指定する
    When 次のパッチを追加:
      | source host | destination port |
      |           1 |                1 |
      |           2 |                2 |
    And 各テスト用ホストが次のようにパケットを送信:
      | source host | destination host |
      |           1 |                2 |
      |           2 |                1 |
    Then テスト対象の OpenFlow スイッチの次のポートに PacketIn が届く:
      | port |
      |    1 |
      |    2 |

  Scenario: パッチを指定する その2
    When 次のパッチを追加:
      | source host | destination port |
      |           1 |                1 |
      |           2 |                1 |
    And 各テスト用ホストが次のようにパケットを送信:
      | source host | destination host |
      |           1 |                2 |
      |           2 |                1 |
    Then テスト対象の OpenFlow スイッチの次のポートに PacketIn が届く:
      | port |
      |    1 |
    And テスト対象の OpenFlow スイッチの次のポートには PacketIn が届かない:
      | port |
      |    2 |

