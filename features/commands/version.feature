Feature: net_tester --version コマンド

  よくある --version オプション:
  $ net_tester --version

  Scenario: --version オプション
    When コマンド `net_tester --version` を実行
    Then 終了ステータスは 0
    And コマンドの出力は "0.2.0" を含む
