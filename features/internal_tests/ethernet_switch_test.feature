Feature: イーサネットスイッチをテスト

  NetTester 開発者として、
  イーサネットスイッチを NetTester でテストできることを確認したい
  なぜなら、イーサネットスイッチのテストでは
  仮想ホストやパッチといった NetTester の基本的機能をすべて使うから

  Scenario: 仮想ホスト 2 台でパケットを送受信
    Given テスト対象のイーサネットスイッチ
    And DPID が 0x123 の NetTester 物理スイッチ
    And NetTester を起動
    And テストホスト 2 台
    And NetTester 物理スイッチとテスト対象のスイッチを次のように接続:
      | Physical Port | Testee Port |
      |             2 |           1 |
      |             3 |           2 |
    When 次のパッチを追加:
      | Virtual Port | Physical Port |
      |            2 |             2 |
      |            3 |             3 |
    And 各テストホストから次のようにパケットを送信:
      | Source Host | Destination Host |
      |           1 |                2 |
      |           2 |                1 |
    Then 各テストホストは次のようにパケットを受信する:
      | Source Host | Destination Host |
      |           1 |                2 |
      |           2 |                1 |
