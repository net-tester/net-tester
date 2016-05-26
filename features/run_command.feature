Feature: net_tester run コマンド
  Scenario: ホスト 3 台を起動
    When I run `net_tester run --device eth1 --nhost 3`
    Then the exit status should be 0

  Scenario: 2 回実行するとエラー
    Given I successfully run `net_tester run --device eth1 --nhost 3`
    When I run `net_tester run --device eth1 --nhost 3`
    Then the output should contain:
      """
      NetTester is already running
      """
