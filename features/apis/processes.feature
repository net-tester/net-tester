Feature: NetTester API サーバの processes API 実行

  Scenario: process 実行なしで processess の取得
    When GET "/processes"
    Then HTTP レスポンスは "200"
    And JSON レスポンスは:
      """
      []
      """

  Scenario: process の実行
    Given DPID が 0x123 の NetTester 物理スイッチ
    And PUT "/hosts/host1"
      """
      {
        "mac_address": "00:00:00:00:00:01",
        "ip_address": "192.168.0.100",
        "netmask": "255.255.255.0",
        "gateway": "192.168.0.1",
        "virtual_port_number": 2,
        "physical_port_number": 2
      }
      """
    When POST "/processes"
      """
      {
        "host_name": "host1",
        "command": "hostname"
      }
      """
    Then HTTP レスポンスは "200"
    And JSON レスポンスにキー "id" 値 "1" を含む

  Scenario: process 実行後の結果取得
    Given DPID が 0x123 の NetTester 物理スイッチ
    And PUT "/hosts/host1"
      """
      {
        "mac_address": "00:00:00:00:00:01",
        "ip_address": "192.168.0.100",
        "netmask": "255.255.255.0",
        "gateway": "192.168.0.1",
        "virtual_port_number": 2,
        "physical_port_number": 2
      }
      """
    And POST "/processes"
      """
      {
        "host_name": "host1",
        "command": "echo OK",
        "initial_wait": 0,
        "process_wait": 0
      }
      """
    When GET "/processes/2" の後、JSON レスポンスにキー "status" 値 "finished" が含まれるのを待つ
    Then HTTP レスポンスは "200"
    And JSON レスポンスは:
      """
      {
        "id": 2,
        "host_name": "host1",
        "log_dir": "tmp/aruba/processes/2",
        "stdout_file": "tmp/aruba/processes/2/stdout.log",
        "stderr_file": "tmp/aruba/processes/2/stderr.log",
        "status": "finished",
        "initial_wait": 0,
        "process_wait": 0,
        "stderr": "",
        "stdout": "OK\n"
      }
      """

  Scenario: process 実行後の全結果取得
    Given DPID が 0x123 の NetTester 物理スイッチ
    And PUT "/hosts/host1"
      """
      {
        "mac_address": "00:00:00:00:00:01",
        "ip_address": "192.168.0.100",
        "netmask": "255.255.255.0",
        "gateway": "192.168.0.1",
        "virtual_port_number": 2,
        "physical_port_number": 2
      }
      """
    And POST "/processes"
      """
      {
        "host_name": "host1",
        "command": "echo Process1",
        "initial_wait": 0,
        "process_wait": 0
      }
      """
    And POST "/processes"
      """
      {
        "host_name": "host1",
        "command": "echo Process2",
        "initial_wait": 0,
        "process_wait": 0
      }
      """
    And POST "/processes"
      """
      {
        "host_name": "host1",
        "command": "echo Process3",
        "initial_wait": 0,
        "process_wait": 0
      }
      """
    And GET "/processes/3" の後、JSON レスポンスにキー "status" 値 "finished" が含まれるのを待つ
    And GET "/processes/4" の後、JSON レスポンスにキー "status" 値 "finished" が含まれるのを待つ
    And GET "/processes/5" の後、JSON レスポンスにキー "status" 値 "finished" が含まれるのを待つ
    When GET "/processes"
    Then HTTP レスポンスは "200"
    And JSON レスポンスは:
      """
      [
        {
          "id": 3,
          "host_name": "host1",
          "log_dir": "tmp/aruba/processes/3",
          "stdout_file": "tmp/aruba/processes/3/stdout.log",
          "stderr_file": "tmp/aruba/processes/3/stderr.log",
          "status": "finished",
          "initial_wait": 0,
          "process_wait": 0,
          "stderr": "",
          "stdout": "Process1\n"
        },
        {
          "id": 4,
          "host_name": "host1",
          "log_dir": "tmp/aruba/processes/4",
          "stdout_file": "tmp/aruba/processes/4/stdout.log",
          "stderr_file": "tmp/aruba/processes/4/stderr.log",
          "status": "finished",
          "initial_wait": 0,
          "process_wait": 0,
          "stderr": "",
          "stdout": "Process2\n"
        },
        {
          "id": 5,
          "host_name": "host1",
          "log_dir": "tmp/aruba/processes/5",
          "stdout_file": "tmp/aruba/processes/5/stdout.log",
          "stderr_file": "tmp/aruba/processes/5/stderr.log",
          "status": "finished",
          "initial_wait": 0,
          "process_wait": 0,
          "stderr": "",
          "stdout": "Process3\n"
        }
      ]
      """

