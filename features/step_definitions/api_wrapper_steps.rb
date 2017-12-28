require 'cucumber/api_steps'

When /^(GET|POST|PUT|DELETE) リクエストを "([^"]*)" に送信$/ do |*args|
  header 'Accept', "application/json"
  header 'Content-Type', "application/json"
  request_type = args.shift
  path = args.shift
  input = args.shift
  step %(I send a #{request_type} request to "#{path}"), input
end

When /^(GET|POST|PUT|DELETE) リクエストを "([^"]*)" に送信し、JSON レスポンスにキー "([^"]*)" 値 "([^"]*)" が含まれるのを待つ$/ do |*args|
  request_type = args.shift
  path = args.shift
  key = args.shift
  value = args.shift
  input = args.shift
  error = nil
  10.times do |i|
    step %(#{request_type} リクエストを "#{path}" に送信), input
    begin
      step %(JSON レスポンスにキー "#{key}" 値 "#{value}" を含む)
      error = nil
      break
    rescue RSpec::Expectations::ExpectationNotMetError => e
      error = e
    end
    sleep(1)
  end
  raise error unless error.nil?
end

When /^(POST|PUT) リクエストで "([^"]*)" にファイル "([^"]*)" を "([^"]*)" の形式でアップロード$/ do |verb, path, file_name, content_type|
  post path, uploaded_file: {source: Rack::Test::UploadedFile.new(Rails.root.join('features/support/attachments/', file_name), content_type)}
end

Then /^レスポンスのステータスコードが "([^"]*)" である$/ do |status|
  step %(the response status should be "#{status}")
end

Then /^JSON レスポンスが以下である$/ do |json|
  step %(the JSON response should be:), json
end

Then /^JSON レスポンスにキー "([^"]*)" 値 "([^"]*)" を含む$/ do |json_path, text|
  step %(the JSON response should have "#{json_path}" with the text "#{text}")
end
