@firewall_example
Feature: ファイアウォールのテスト

  NetTester のユーザとして
  ファイアウォールの設定がまちがっていないかテストしたい
  なぜならファイアウォールの設定は複雑でよくミスるから

  Background:
    Given NetTester で次のホストを起動:
      | Hostname |    IP Address | Virtual Port |
      | client   |   192.168.0.1 |            2 |
      | server   | 192.168.0.100 |            3 |
    And NetTester で次のパッチを追加:
      | Virtual Port | Physical Port |
      |            2 |             2 |
      |            3 |             3 |

  Scenario: 宛先ポートが 8080 番の HTTP は通る
    Given NetTester のホスト "server" で Web サーバをポート 8080 番で起動
    When NetTester のホスト "client" から http://192.168.0.100:8080/ を HTTP GET
    Then HTTP ステータス 200 が返る

  Scenario: 宛先ポートが 3000 番の HTTP はブロック
    Given NetTester のホスト "server" で Web サーバをポート 3000 番で起動
    When NetTester のホスト "client" から http://192.168.0.100:3000/ を HTTP GET
    Then HTTP GET がタイムアウトで失敗する
