require 'spork'

Spork.prefork do
  require 'bundler'
  Bundler.setup(:default, :development)
  require 'rspec/core'
  require 'rack/test'
  require 'chunky_png'

  RSpec.configure do |config|
    config.fail_fast = true

    config.expect_with :rspec do |c|
      c.syntax = :expect
    end
  end
end
