Feature: NetTester API サーバの material API 実行

  Scenario: ファイル登録なしで materials の取得
    When GET リクエストを "/materials" に送信
    Then レスポンスのステータスコードが "200" である
    And JSON レスポンスが以下である
      """
      []
      """

  Scenario: ファイルのアップロード
    When POST リクエストで "/materials" にファイル "material1.txt" を "application/octet-stream" の形式でアップロード
    Then 次のファイルができる:
      | materials/material1.txt |
    And レスポンスのステータスコードが "200" である
    And JSON レスポンスが以下である
      """
      {}
      """

  Scenario: ファイル登録後に materials の取得
    Given POST リクエストで "/materials" にファイル "material1.txt" を "application/octet-stream" の形式でアップロード
    And POST リクエストで "/materials" にファイル "material2.txt" を "application/octet-stream" の形式でアップロード
    When GET リクエストを "/materials" に送信
    Then レスポンスのステータスコードが "200" である
    And JSON レスポンスが以下である
      """
      [
        "material1.txt",
        "material2.txt"
      ]
      """
