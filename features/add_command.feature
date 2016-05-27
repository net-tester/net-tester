Feature: net_tester add コマンド

  NetTester ユーザは、"net_tester add --vport ポート番号 --port ポート番号" コマンドで
  仮想ホストを仮想パッチでテスト対象のネットワークに接続できる。

  実行例:
  $ net_tester add --vport 1 --port 1

  Background:
    Given テスト対象のネットワークにイーサネットスイッチが 1 台
    And NetTester でテストホスト 2 台を起動
    And DPID が 0xdef の NetTester 物理スイッチ
    And NetTester 物理スイッチとテスト対象のスイッチを次のように接続:
      | Physical Port | Testee Port |
      |             1 |           1 |
      |             2 |           2 |
    And NetTester 仮想スイッチと物理スイッチを次のように接続:
      | Virtual Port | Physical Port |
      |            3 |             3 |

  Scenario: パッチを追加して送受信に成功
    When コマンド `net_tester add --vport 1 --port 1` を実行
    Then 終了ステータスは 0
    And コマンドの出力はなし
    When コマンド `net_tester add --vport 2 --port 2` を実行
    Then 終了ステータスは 0
    And コマンドの出力はなし
    When 各テストホストから次のようにパケットを送信:
      | Source Host | Destination Host |
      |           1 |                2 |
      |           2 |                1 |
    And コマンド `net_tester stats host1` の実行に成功
    Then コマンド "net_tester stats host1" の出力は次のとおり:
      """
      Packets sent:
        host1 -> host2 = 1 packet
      Packets received:
        host2 -> host1 = 1 packet
      """

  Scenario: --vport を指定しないとエラー
    When コマンド `net_tester add --port 1` を実行
    Then 終了ステータスは 0 ではない
    And コマンドの出力は "--vport option is mandatory" を含む

  Scenario: --port を指定しないとエラー
    When コマンド `net_tester add --vport 1` を実行
    Then 終了ステータスは 0 ではない
    And コマンドの出力は "--port option is mandatory" を含む

  Scenario: --vport に大きすぎるポート番号を指定するとエラー
    When コマンド `net_tester add --vport 3 --port 1` を実行
    Then 終了ステータスは 0 ではない
    And コマンドの出力は "3: no such virtual port" を含む

  Scenario: --vport にマイナスのポート番号を指定するとエラー
    When コマンド `net_tester add --vport -1 --port 1` を実行
    Then 終了ステータスは 0 ではない
    And コマンドの出力は "-1: invalid virtual port" を含む

  Scenario: --port に大きすぎるポート番号を指定するとエラー
    When コマンド `net_tester add --vport 1 --port 3` を実行
    Then 終了ステータスは 0 ではない
    And コマンドの出力は "3: no such port" を含む

  Scenario: --port にマイナスのポート番号を指定するとエラー
    When コマンド `net_tester add --vport 1 --port -1` を実行
    Then 終了ステータスは 0 ではない
    And コマンドの出力は "-1: invalid port" を含む

  Scenario: run せずに add するとエラー
    Given コマンド `net_tester kill` の実行に成功
    When I run `net_tester add --vport 1 --port 1`
    Then the exit status should not be 0
    Then the output should contain:
      """
      NetTester is not running
      """
