Feature: net_tester delete コマンド

  NetTester ユーザは、"net_tester delete --vport ポート番号 --port ポート番号" コマンドで
  仮想パッチを削除できる。

  実行例:
  $ net_tester delete --vport 2 --port 2

  Background:
    Given テスト対象のイーサネットスイッチ
    And DPID が 0x123 の NetTester 物理スイッチ
    And NetTester を起動
    And テストホスト 2 台
    And NetTester 物理スイッチとテスト対象のスイッチを次のように接続:
      | Physical Port | Testee Port |
      |             2 |           2 |
      |             3 |           3 |

  Scenario: --vport を指定しないとエラー
    When コマンド `net_tester delete --port 2 -S sockets` を実行
    Then 終了ステータスは 0 ではない
    And コマンドの出力は "--vport option is mandatory" を含む

  Scenario: --port を指定しないとエラー
    When コマンド `net_tester delete --vport 2 -S sockets` を実行
    Then 終了ステータスは 0 ではない
    And コマンドの出力は "--port option is mandatory" を含む

  Scenario: --vport に大きすぎるポート番号を指定するとエラー
    When コマンド `net_tester delete --vport 4 --port 2 -S sockets` を実行
    Then 終了ステータスは 0 ではない
    And コマンドの出力は "4: no such virtual port" を含む

  Scenario: --vport にマイナスのポート番号を指定するとエラー
    When コマンド `net_tester delete --vport -1 --port 2 -S sockets` を実行
    Then 終了ステータスは 0 ではない
    And コマンドの出力は "-1: invalid virtual port" を含む

  Scenario: --port に大きすぎるポート番号を指定するとエラー
    When コマンド `net_tester delete --vport 2 --port 4 -S sockets` を実行
    Then 終了ステータスは 0 ではない
    And コマンドの出力は "4: no such port" を含む

  Scenario: --port にマイナスのポート番号を指定するとエラー
    When コマンド `net_tester delete --vport 2 --port -1 -S sockets` を実行
    Then 終了ステータスは 0 ではない
    And コマンドの出力は "-1: invalid port" を含む

  Scenario: run せずに delete するとエラー
    Given コマンド `net_tester kill -S sockets` の実行に成功
    When I run `net_tester delete --vport 2 --port 2 -S sockets`
    Then the exit status should not be 0
    Then the output should contain:
      """
      NetTester is not running
      """
