Feature: NetTester API サーバの testlet API 実行

  Scenario: ファイル登録なしで testlets の取得
    When GET リクエストを "/testlets" に送信
    Then レスポンスのステータスコードが "200" である
    And JSON レスポンスが以下である
      """
      []
      """

  Scenario: ファイルのアップロード
    When POST リクエストで "/testlets" にファイル "testlet1.txt" を "application/octet-stream" の形式でアップロード
    Then 次のファイルができる:
      | testlets/testlet1.txt |
    And レスポンスのステータスコードが "200" である
    And JSON レスポンスが以下である
      """
      {}
      """

  Scenario: ファイル登録後に testlets の取得
    Given POST リクエストで "/testlets" にファイル "testlet1.txt" を "application/octet-stream" の形式でアップロード
    And POST リクエストで "/testlets" にファイル "testlet2.txt" を "application/octet-stream" の形式でアップロード
    When GET リクエストを "/testlets" に送信
    Then レスポンスのステータスコードが "200" である
    And JSON レスポンスが以下である
      """
      [
        "testlet1.txt",
        "testlet2.txt"
      ]
      """
