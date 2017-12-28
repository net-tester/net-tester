Feature: NetTester API サーバの uploaded_files API 実行

  Scenario: ファイル登録なしで uploaded_files の取得
    When GET リクエストを "/uploaded_files" に送信
    Then レスポンスのステータスコードが "200" である
    And JSON レスポンスが以下である
      """
      []
      """

  Scenario: ファイルのアップロード
    When POST リクエストで "/uploaded_files" にファイル "upload-test1.txt" を "application/octet-stream" の形式でアップロード
    Then 次のファイルができる:
      | upload/upload-test1.txt |
    And レスポンスのステータスコードが "200" である
    And JSON レスポンスが以下である
      """
      {}
      """

  Scenario: ファイル登録後に uploaded_files の取得
    Given POST リクエストで "/uploaded_files" にファイル "upload-test1.txt" を "application/octet-stream" の形式でアップロード
    And POST リクエストで "/uploaded_files" にファイル "upload-test2.txt" を "application/octet-stream" の形式でアップロード
    When GET リクエストを "/uploaded_files" に送信
    Then レスポンスのステータスコードが "200" である
    And JSON レスポンスが以下である
      """
      [
        "upload-test1.txt",
        "upload-test2.txt"
      ]
      """
