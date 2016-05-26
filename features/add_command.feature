Feature: net_tester add コマンド
  Scenario: run せずに add するとエラー
    When I run `net_tester add --vport 1 --port 1`
    Then the exit status should not be 0
    Then the output should contain:
      """
      NetTester is not running
      """
