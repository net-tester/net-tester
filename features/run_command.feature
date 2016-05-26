Feature: net_tester run コマンド
  Scenario: ホスト 3 台を起動
    When I run `net_tester run --device eth1 --nhost 3`
    Then the exit status should be 0
    And the following files should exist:
      | log/NetTesterController.log         |
      | log/vhost.host1.log                 |
      | log/vhost.host2.log                 |
      | log/vhost.host3.log                 |
      | tmp/pids/NetTesterController.pid    |
      | tmp/pids/vhost.host1.pid            |
      | tmp/pids/vhost.host2.pid            |
      | tmp/pids/vhost.host3.pid            |

  Scenario: 2 回実行するとエラー
    Given I successfully run `net_tester run --device eth1 --nhost 3`
    When I run `net_tester run --device eth1 --nhost 3`
    Then the exit status should not be 0
    And the output should contain:
      """
      NetTester is already running
      """
