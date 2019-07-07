# frozen_string_literal: true

require 'bundler'
Bundler.setup

gemspec = eval(File.read('rack-passbook.gemspec'))

task build: "#{gemspec.full_name}.gem"

file "#{gemspec.full_name}.gem" => gemspec.files + ['rack-passbook.gemspec'] do
  system 'gem build rack-passbook.gemspec'
end
