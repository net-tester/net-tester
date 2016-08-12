Feature: "net_tester run" コマンド

  NetTester ユーザは、"net_tester run" コマンドで
  NetTester を起動できる。

  起動するものは次のとおり:
  - OpenFlow コントローラ
  - 仮想スイッチ
  - 仮想ホスト
  - 仮想リンク

  Scenario: ホスト 3 台を起動
    When コマンド `net_tester run --nhost 3 --device eth1 --dpid 0x123 -L log -P pids -S sockets` を実行
    Then 終了ステータスは 0
    And コマンドの出力はなし
    And 次のファイルができる:
      | log/NetTesterController.log  |
      | log/vhost.host1.log          |
      | log/vhost.host2.log          |
      | log/vhost.host3.log          |
      | pids/NetTesterController.pid |
      | pids/vhost.host1.pid         |
      | pids/vhost.host2.pid         |
      | pids/vhost.host3.pid         |

  Scenario: ホスト数 <= 0 だとエラー
    When コマンド `net_tester run --device eth1 --nhost 0 --dpid 0x123 -S sockets` を実行
    Then 終了ステータスは 0 ではない
    And コマンドの出力は "--nhost must be > 0" を含む

  Scenario: 2 回実行するとエラー
    Given コマンド `net_tester run --device eth1 --nhost 3 --dpid 0x123 -S sockets` の実行に成功
    When コマンド `net_tester run --device eth1 --nhost 3 --dpid 0x123 -S sockets` を実行
    Then 終了ステータスは 0 ではない
    And コマンドの出力は "NetTester is already running" を含む
