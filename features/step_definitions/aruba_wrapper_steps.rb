# coding: utf-8
# frozen_string_literal: true
When(/^コマンド `([^`]+)` を実行$/) do |command|
  step "I run `#{command}`"
end

Then(/^終了ステータスは (\d+)$/) do |status|
  step "the exit status should be #{status}"
end

Then(/^コマンドの出力はなし$/) do
  expect(all_commands.map(&:output).join("\n")).to have_output_size 0
end
