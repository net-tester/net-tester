Feature: net_tester stats コマンド
  Background:
    Given テスト対象のネットワークにイーサネットスイッチが 1 台
    And NetTester とテストホスト 2 台を起動
    And DPID が 0xdef の NetTester 物理スイッチ
    And NetTester 物理スイッチとテスト対象のスイッチを次のように接続:
      | Physical Port | Testee Port |
      |             1 |           1 |
      |             2 |           2 |
    And NetTester 仮想スイッチと物理スイッチを次のように接続
      | Virtual Port | Physical Port |
      |            3 |             3 |
    And 次のパッチを追加:
      | Virtual Port | Physical Port |
      |            1 |             1 |
      |            2 |             2 |

  Scenario: パケットを送受信せずに net_tester stats
    When I successfully run `net_tester stats host1`
    Then the output should be 0 bytes long

  Scenario: パケットを送受信して net_tester stats 
    When 各テストホストから次のようにパケットを送信:
      | Source Host | Destination Host |
      |           1 |                2 |
    And I successfully run `net_tester stats host2`
    Then the output from "net_tester stats host2" should contain exactly:
      """
      Packets received:
        host1 -> host2 = 1 packet
      """
