Feature: イーサネットスイッチをテスト
  Background:
    Given テスト対象のネットワークにイーサネットスイッチが 1 台

  Scenario: ホスト 2 台でパケットを送受信
    Given テスト用の仮想ホストが 2 台
    And NetTester を起動
    When 各テスト用ホストが次のようにパケットを送信:
      | source host | destination host |
      |           1 |                2 |
      |           2 |                1 |
    Then 各テスト用ホストは次のようにパケットを受信する:
      | source host | destination host |
      |           1 |                2 |
      |           2 |                1 |

  Scenario: ホスト 3 台でパケットを送受信
    Given テスト用の仮想ホストが 3 台
    And NetTester を起動
    When 各テスト用ホストが次のようにパケットを送信:
      | source host | destination host |
      |           1 |                2 |
      |           2 |                1 |
    Then 各テスト用ホストは次のようにパケットを受信する:
      | source host | destination host |
      |           1 |                2 |
      |           2 |                1 |
