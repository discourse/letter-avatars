require 'rack/utils'
require 'date'
require 'letter_avatar'

class LetterAvatarApp

  VERSION = 1

  STATIC_ASSETS = {
    '/.well-known/dnt-policy.txt' => File.read(File.dirname(__FILE__) << "/dnt-policy-1.0.txt"),
    # allow everything so crawlers can download images
    '/robots.txt' => "User-Agent: *\nAllow: /"
  }

  def self.static_asset(path)
    if text = STATIC_ASSETS[path]
      [200, {
        'Content-Type' => 'text/plain',
        'Cache-Control' => 'public, max-age=86400',
        'Last-Modified' => 'Tue, 11 Jan 2000 00:57:26 GMT',
        'Content-Length' => text.bytesize.to_s,
        'Expires' => (Time.now.to_date + 2).httpdate
      }, [text]]
    end
  end

  def self.call(env)
    unless env['REQUEST_METHOD'] == 'GET'
      return error(405, "Only GET requests are supported")
    end

    unless env['PATH_INFO'] =~ %r{^/letter/(\w)/([0-9A-Fa-f]{6})/(\d+)\.png$}
      return static_asset(env['PATH_INFO']) || error(404, "Resource not found")
    end

    letter = $1.upcase
    size = $3.to_i
    r, g, b = $2.scan(/../).map { |i| i.to_i(16) }


    avatar = LetterAvatar.generate(letter, size, r, g, b)

    expires = (Time.now.to_date + 720).httpdate

    return [200, {
      'Content-Type' => 'image/png',
      'Cache-Control' => 'public, max-age=157788000',
      'Content-Length' => avatar.bytesize.to_s,
      'Last-Modified' => 'Tue, 11 Jan 2000 00:57:26 GMT',
      'Expires' => expires,
      'Etag' => "#{letter}#{size}#{r}#{g}#{b}#{VERSION}",
      'Vary' => 'Accept-Encoding'
    }, [avatar]]
  end

  def self.error(code, msg)
    [code, [['Content-Type', 'text/plain']], [msg]]
  end
end
