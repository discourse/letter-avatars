$:.unshift File.dirname(__FILE__) << "/lib"
require 'rack'
require 'letter_avatar_app'

run LetterAvatarApp
