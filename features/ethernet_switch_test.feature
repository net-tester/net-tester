Feature: イーサネットスイッチをテスト
  Background:
    Given テスト対象のネットワークにイーサネットスイッチが 1 台

  Scenario: ホスト 2 台でパケットを送受信
    And NetTester とテストホスト 2 台を起動
    When 次のパッチを追加:
      | virtual port | physical port |
      |            1 |             1 |
      |            2 |             2 |
    And 各テストホストから次のようにパケットを送信:
      | source host | destination host |
      |           1 |                2 |
      |           2 |                1 |
    Then 各テストホストは次のようにパケットを受信する:
      | source host | destination host |
      |           1 |                2 |
      |           2 |                1 |

  Scenario: ホスト 3 台でパケットを送受信
    And NetTester とテストホスト 2 台を起動
    When 次のパッチを追加:
      | virtual port | physical port |
      |            1 |             1 |
      |            2 |             2 |
    And 各テストホストから次のようにパケットを送信:
      | source host | destination host |
      |           1 |                2 |
      |           2 |                1 |
    Then 各テストホストは次のようにパケットを受信する:
      | source host | destination host |
      |           1 |                2 |
      |           2 |                1 |
