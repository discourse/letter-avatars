$:.unshift File.dirname(__FILE__) << "/lib"
require 'rack'

if ENV['LOGSTASH_SERVER_URL']
  require 'rack/logstasher'
  require 'logstash-logger'
  require 'uri'
  logstash_url = URI(ENV['LOGSTASH_SERVER_URL'])

  use Rack::Logstasher::Logger,
      LogStashLogger.new(
        type: logstash_url.scheme,
        host: logstash_url.host,
        port: logstash_url.port
      )
end

require 'letter_avatar_app'
run LetterAvatarApp
