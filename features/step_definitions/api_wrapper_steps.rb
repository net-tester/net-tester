require 'cucumber/api_steps'

When /^(GET|POST|PUT|DELETE) リクエストを "([^"]*)" に送信$/ do |*args|
  header 'Accept', "application/json"
  header 'Content-Type', "application/json"
  request_type = args.shift
  path = args.shift
  input = args.shift
  step %(I send a #{request_type} request to "#{path}"), input
end

Then /^レスポンスのステータスコードが "([^"]*)" である$/ do |status|
  step %(the response status should be "#{status}")
end

Then /^JSON レスポンスが以下である$/ do |json|
  step %(the JSON response should be:), json
end
