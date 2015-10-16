$:.unshift File.dirname(__FILE__) << "/lib"
require 'rack'

if ENV['LOGSTASH_SERVER_URL']
  require 'rack/logstash'

  puts "* Logging all requests to logstash server at #{ENV['LOGSTASH_SERVER_URL']}"

  use Rack::Logstash, ENV['LOGSTASH_SERVER_URL'], tags: %w{letter-avatars}
end

require 'letter_avatar_app'
run LetterAvatarApp
