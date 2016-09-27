Feature: net_tester add_p2p コマンド

  NetTester ユーザは、"net_tester add_p2p --ports ポート番号,ポート番号" コマンドで
  テスト対象のネットワーク機器間を直結できる。

  実行例:
  $ net_tester add_p2p --ports 3,5

  Background:
    Given テスト対象のイーサネットスイッチ
    And DPID が 0x123 の NetTester 物理スイッチ
    And NetTester を起動
    And テストホスト 2 台
    And NetTester 物理スイッチとテスト対象のスイッチを次のように接続:
      | Physical Port | Testee Port |
      |             2 |           2 |
      |             3 |           3 |

  Scenario: パッチが重複するとエラー
    When コマンド `net_tester add_p2p --ports 2,3 -S sockets` の実行に成功
    Then コマンド `net_tester add --port 2 --vport 2 -S sockets` を実行
    And 終了ステータスは 0 ではない
    And コマンドの出力は "Port 2 is already in use by other patch" を含む

  Scenario: --ports を指定しないとエラー
    When コマンド `net_tester add_p2p -S sockets` を実行
    Then 終了ステータスは 0 ではない
    And コマンドの出力は "--ports option is mandatory" を含む

  Scenario: --ports で指定するポートの数が足りないとエラー
    When コマンド `net_tester add_p2p --ports 2 -S sockets` を実行
    Then 終了ステータスは 0 ではない
    And コマンドの出力は "2: invalid port pair" を含む

  Scenario: --ports で指定するポートの数が多いとエラー
    When コマンド `net_tester add_p2p --ports 2,3,4 -S sockets` を実行
    Then 終了ステータスは 0 ではない
    And コマンドの出力は "2,3,4: invalid port pair" を含む

  Scenario: --ports で指定するポート番号が同じだとエラー
    When コマンド `net_tester add_p2p --ports 3,3 -S sockets` を実行
    Then 終了ステータスは 0 ではない
    And コマンドの出力は "3,3: invalid port pair" を含む

  Scenario: --ports で指定するポートにマイナスのポート番号が含まれるとエラー
    When コマンド `net_tester add_p2p --ports 2,-3 -S sockets` を実行
    Then 終了ステータスは 0 ではない
    And コマンドの出力は "2,-3: invalid port pair" を含む

  Scenario: run せずに add_p2p するとエラー
    Given コマンド `net_tester kill -S sockets` の実行に成功
    When I run `net_tester add_p2p --ports 2,3 -S sockets`
    Then the exit status should not be 0
    Then the output should contain:
      """
      NetTester is not running
      """
