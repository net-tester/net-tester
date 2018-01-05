Feature: API

  Scenario: sites の取得
    When GET "/sites"
    Then HTTP レスポンスは "200"
    And JSON レスポンスは:
      """
      {}
      """

  Scenario: sites の削除
    When DELETE "/sites"
    Then HTTP レスポンスは "204"
    And OpenFlow コントローラが停止
    And すべてのスイッチが停止
    And すべてのリンクが停止
    And 次の仮想ホストがすべて停止:
      | host1 |
      | host2 |
      | host3 |
    And 次のファイルが存在しない:
      | log/NetTesterController.log  |
      | log/vhost.host1.log          |
      | log/vhost.host2.log          |
      | log/vhost.host3.log          |
      | pids/NetTesterController.pid |
      | pids/vhost.host1.pid         |
      | pids/vhost.host2.pid         |
      | pids/vhost.host3.pid         |
      | /etc/netns/host1 |
      | /etc/netns/host2 |
      | /etc/netns/host3 |

  Scenario: NetTester 起動時の sites の削除
    Given コマンド `net_tester run --device eth1 --nhost 3 --dpid 0x123 -S sockets` の実行に成功
    When DELETE "/sites"
    Then HTTP レスポンスは "204"
    And OpenFlow コントローラが停止
    And すべてのスイッチが停止
    And すべてのリンクが停止
    And 次の仮想ホストがすべて停止:
      | host1 |
      | host2 |
      | host3 |
    And 次のファイルが存在しない:
      | log/NetTesterController.log  |
      | log/vhost.host1.log          |
      | log/vhost.host2.log          |
      | log/vhost.host3.log          |
      | pids/NetTesterController.pid |
      | pids/vhost.host1.pid         |
      | pids/vhost.host2.pid         |
      | pids/vhost.host3.pid         |
      | /etc/netns/host1 |
      | /etc/netns/host2 |
      | /etc/netns/host3 |

