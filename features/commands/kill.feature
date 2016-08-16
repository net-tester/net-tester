Feature: "net_tester kill" コマンド

  NetTester ユーザは、"net_tester kill" コマンドで
  起動中の NetTester を停止できる。

  kill コマンドは次のものを停止する:
  - OpenFlow コントローラ
  - 仮想スイッチ
  - 仮想ホスト
  - 仮想リンク

  Scenario: 起動中の NetTester を "net_tester kill" で停止
    Given DPID が 0x123 の NetTester 物理スイッチ
    And NetTester を起動
    And テストホスト 3 台
    When コマンド `net_tester kill` を実行
    Then 終了ステータスは 0
    And コマンドの出力はなし
    And OpenFlow コントローラが停止
    And すべてのスイッチが停止
    And すべてのリンクが停止
    And 次の仮想ホストがすべて停止:
      | host1 |
      | host2 |
      | host3 |

  Scenario: NetTester を起動せずいきなり kill
    When コマンド `net_tester kill` を実行
    Then 終了ステータスは 0
    And コマンドの出力はなし

