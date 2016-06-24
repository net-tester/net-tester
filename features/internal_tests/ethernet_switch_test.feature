Feature: イーサネットスイッチをテスト
  Background:
    Given イーサネットスイッチ (DPID = "0x1", tcp_port = 6654)
    And NetTester 物理スイッチ (DPID = "0x123")
    And NetTester を DPID = "0x123" で起動
    And NetTester のホスト 2 台を起動
    And NetTester 物理スイッチとテスト対象のスイッチを次のように接続:
      | Physical Port | Testee Port |
      |             1 |           1 |
      |             2 |           2 |
    And NetTester 仮想スイッチと物理スイッチを次のように接続:
      | Virtual Port | Physical Port |
      |            3 |             3 |

  Scenario: ホスト 2 台でパケットを送受信
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
