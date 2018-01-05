Feature: NetTester API サーバの testlet API 実行

  Scenario: ファイル登録なしで testlets の取得
    When GET "/testlets"
    Then HTTP レスポンスは "200"
    And JSON レスポンスは:
      """
      []
      """

  Scenario: ファイルのアップロード
    When POST "/testlets" で "tcp_server.sh" を "application/octet-stream" の形式でアップロード
    Then 次のファイルができる:
      | testlets/tcp_server.sh |
    And HTTP レスポンスは "200"
    And JSON レスポンスは:
      """
      {}
      """

  Scenario: ファイル登録後に testlets の取得
    Given POST "/testlets" で "tcp_server.sh" を "application/octet-stream" の形式でアップロード
    And POST "/testlets" で "tcp_client.sh" を "application/octet-stream" の形式でアップロード
    When GET "/testlets"
    Then HTTP レスポンスは "200"
    And JSON レスポンスは:
      """
      [
        "tcp_client.sh",
        "tcp_server.sh"
      ]
      """
