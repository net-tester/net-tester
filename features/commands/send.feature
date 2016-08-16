Feature: "net_tester send" コマンド

  NetTester ユーザは、"net_tester send --source ホスト名1 --dest ホスト名2" コマンドで
  仮想ホスト間でパケットを送受信できる。

  実行例:
  $ net_tester send --source host1 --dest host2

  Background:
    Given テスト対象のイーサネットスイッチ
    And DPID が 0x123 の NetTester 物理スイッチ
    And NetTester を起動
    And テストホスト 2 台
    And NetTester 物理スイッチとテスト対象のスイッチを次のように接続:
      | Physical Port | Testee Port |
      |             2 |           2 |
      |             3 |           3 |
    And 次のパッチを追加:
      | Virtual Port | Physical Port |
      |            2 |             2 |
      |            3 |             3 |

  Scenario: host1 の送受信パケット数を "net_tester stats host1" で表示
    When コマンド `net_tester send --source host1 --dest host2 -S sockets` を実行
    Then 終了ステータスは 0
    And コマンドの出力はなし
    When コマンド `net_tester stats host1 -S sockets` の実行に成功
    Then コマンド "net_tester stats host1 -S sockets" の出力は次のとおり:
      """
      Packets sent:
        host1 -> host2 = 1 packet
      """
    When コマンド `net_tester stats host2 -S sockets` の実行に成功
    Then コマンド "net_tester stats host2 -S sockets" の出力は次のとおり:
      """
      Packets received:
        host1 -> host2 = 1 packet
      """

  Scenario: ホスト名を指定せず "net_tester send"
    When コマンド `net_tester send -S sockets` を実行
    Then 終了ステータスは 0 ではない
    And コマンドの出力は "--source option is mandatory" を含む

  Scenario: 不正なホスト名を指定
    When コマンド `net_tester send --source NO_SUCH_HOST1 --dest NO_SUCH_HOST2 -S sockets` を実行
    Then 終了ステータスは 0 ではない
    And コマンドの出力は "NO_SUCH_HOST1: no such host" を含む

  Scenario: NetTester が起動していない状態で "net_tester send ..." を実行
    Given コマンド `net_tester kill` の実行に成功
    When コマンド `net_tester send --source host1 --dest host2` を実行
    Then 終了ステータスは 0 ではない
    And コマンドの出力は "NetTester is not running" を含む
