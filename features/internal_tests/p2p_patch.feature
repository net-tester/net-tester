Feature: テスト対象ポート間パッチング
  Background:
    Given DPID が 0x123 の NetTester 物理スイッチ
    And NetTester を起動
    And NetTester 物理スイッチとテスト対象ホストを次のように接続:
      | Physical Port | Host |
      |             2 |    1 |
      |             3 |    2 |
      |             4 |    3 |

  Scenario: NW機器間パッチを設定する
    When 次のNW機器間パッチを追加:
      | Physical Port A | Physical Port B |
      |               3 |               4 |
    And 各テストホストから次のようにパケットを送信:
      | Source Host | Destination Host |
      |           1 |                2 |
      |           2 |                3 |
      |           3 |                1 |
    Then 各テストホストは以下の数パケットを受信する:
      | Source Host | Destination Host | Received Packets |
      |           1 |                2 |                0 |
      |           2 |                3 |                1 |
      |           3 |                1 |                0 |
