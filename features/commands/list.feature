@wip
Feature: net_tester list コマンド
  Background:
    Given NetTester でテストホスト 2 台を起動
    And テスト対象のネットワークにイーサネットスイッチが 1 台
    And DPID が 0x123 の NetTester 物理スイッチ
    And NetTester 物理スイッチとテスト対象のスイッチを次のように接続:
      | Physical Port | Testee Port |
      |             1 |           1 |
      |             2 |           2 |
    And NetTester 仮想スイッチと物理スイッチを次のように接続:
      | Virtual Port | Physical Port |
      |            3 |             3 |

  Scenario: パッチの一覧 (空) を表示
    When I successfully run `net_tester list`
    Then the output should be 0 bytes long

  Scenario: パッチの一覧を表示
    When 次のパッチを追加:
      | Virtual Port | Physical Port |
      |            1 |             1 |
      |            2 |             2 |
    And I successfully run `net_tester list`
    Then the output from "net_tester list" should contain exactly:
      """
      host1 <-> port1
      host2 <-> port2
      """
