# frozen_string_literal: true

When(/^コマンド `([^`]+)` を実行$/) do |command|
  step "I run `#{command}`"
end

When(/^コマンド `([^`]+)` の実行に成功$/) do |command|
  step "I successfully run `#{command}`"
end

Then(/^終了ステータスは (\d+)$/) do |status|
  step "the exit status should be #{status}"
end

Then(/^終了ステータスは (\d+) ではない$/) do |status|
  step "the exit status should not be #{status}"
end

Then(/^コマンドの出力はなし$/) do
  expect(all_commands.map(&:output).join).to have_output_size 0
end

Then(/^コマンドの出力は "([^"]*)" を含む$/) do |output|
  step %(the output should contain "#{output}")
end

Then(/^コマンド "([^"]*)" の出力は次のとおり:$/) do |command, output|
  step %(the output from "#{command}" should contain exactly:), output
end

Then(/^次のファイルができる:$/) do |table|
  step 'the following files should exist:', table
end

Then(/^次のファイルが存在しない:$/) do |table|
  step 'the following files should not exist:', table
end
