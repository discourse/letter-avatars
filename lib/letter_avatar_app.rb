require 'rack/utils'
require 'date'
require 'letter_avatar'
require 'cgi'
require 'unicode_ranges'

class LetterAvatarApp

  VERSION = 4

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

    unless env['PATH_INFO'] =~ %r{^(/v(\d+))?/letter/([%\w.\-]+?)/([0-9A-Fa-f]{6})/(\d+)\.png$}
      return static_asset(env['PATH_INFO']) || error(404, "Resource not found")
    end

    version = ($2 || 1).to_i

    if version > VERSION
      return static_asset(env['PATH_INFO']) || error(404, "Resource not found")
    end

    letter = CGI::unescape($3).unicode_normalize.chr.upcase

    char_type = UnicodeRanges.detect_character_type(letter)

    if char_type == 'none'
      return static_asset(env['PATH_INFO']) || error(404, "Resource not found")
    end

    size = $5.to_i
    r, g, b = $4.scan(/../).map { |i| i.to_i(16) }

    avatar_path = LetterAvatar.generate_path(letter, size, r, g, b, version, char_type)

    expires = (Time.now.to_date + 720).httpdate

    headers = {
      'Content-Type' => 'image/png',
      'Cache-Control' => 'public, max-age=157788000',
      'Last-Modified' => 'Tue, 11 Jan 2000 00:57:26 GMT',
      'Expires' => expires,
      'Etag' => "#{letter}#{size}#{r}#{g}#{b}#{VERSION}",
      'Vary' => 'Accept-Encoding'
    }

    avatar = nil

    if env["HTTP_X_SENDFILE_TYPE"] == "X-Accel-Redirect" && (mapping = env["HTTP_X_ACCEL_MAPPING"])

      from, to = mapping.split("=")
      if (from && to)
        avatar_path.sub!(from, to)
      end
      headers['X-Accel-Redirect'] = avatar_path
    else
      avatar = File.read(avatar_path)
      headers['Content-Length'] = avatar.bytesize.to_s
    end

    return [200, headers, [avatar || ""]]
  end

  def self.error(code, msg)
    [code, [['Content-Type', 'text/plain']], [msg]]
  end
end
