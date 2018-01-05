# frozen_string_literal: true

require 'cucumber/api_steps'

When(/^(GET|POST|PUT|DELETE) "([^"]*)"$/) do |*args|
  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'
  request_type = args.shift
  path = args.shift
  input = args.shift
  step %(I send a #{request_type} request to "#{path}"), input
end

When(/^(GET|POST|PUT|DELETE) "([^"]*)" の後、JSON レスポンスにキー "([^"]*)" 値 "([^"]*)" が含まれるのを待つ$/) do |*args|
  request_type = args.shift
  path = args.shift
  key = args.shift
  value = args.shift
  input = args.shift
  error = nil
  10.times do |_i|
    step %(#{request_type} "#{path}"), input
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

When(/^(POST|PUT) "([^"]*)" で "([^"]*)" を "([^"]*)" の形式でアップロード$/) do |_verb, path, file_name, content_type|
  post path, testlet: { file: Rack::Test::UploadedFile.new(Rails.root.join('features/support/attachments/', file_name), content_type) }
end

Then(/^HTTP レスポンスは "([^"]*)"$/) do |status|
  step %(the response status should be "#{status}")
end

Then(/^JSON レスポンスは:$/) do |json|
  step %(the JSON response should be:), json
end

Then(/^JSON レスポンスにキー "([^"]*)" 値 "([^"]*)" を含む$/) do |json_path, text|
  step %(the JSON response should have "#{json_path}" with the text "#{text}")
end
