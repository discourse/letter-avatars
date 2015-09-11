require 'rack/utils'
require 'date'
require 'letter_avatar'

class LetterAvatarApp

  VERSION = 1

  def self.call(env)
    unless env['REQUEST_METHOD'] == 'GET'
      return error(405, "Only GET requests are supported")
    end

    unless env['PATH_INFO'] =~ %r{^/letter/([a-zA-Z])$}
      return error(404, "Resource not found")
    end

    letter = $1.upcase
    params = Rack::Utils.parse_query(env['QUERY_STRING'])

    r, g, b = if params.has_key?("color")
      hex = params['color']
      unless hex =~ /^[0-9a-fA-F]{6}$/
        return error(400, "Invalid color specifier")
      end
      hex.scan(/../).map { |i| i.to_i(16) }
    else
      [params.fetch('r', 0).to_i, params.fetch('g', 0).to_i, params.fetch('b', 0).to_i]
    end

    size = params.fetch('size', 50).to_i

    avatar = LetterAvatar.generate(letter, size, r, g, b)

    expires = (Time.now.to_date + 720).httpdate

    return [200, {
      'Content-Type' => 'image/png',
      'Cache-Control' => 'public, max-age=157788000',
      'Content-Length' => avatar.bytesize.to_s,
      'Last-Modified' => 'Tue, 11 Jan 2000 00:57:26 GMT',
      'Expires' => expires,
      'Etag' => "#{letter}#{size}#{r}#{g}#{b}#{VERSION}"
    }, [avatar]]
  end

  def self.error(code, msg)
    [code, [['Content-Type', 'text/plain']], [msg]]
  end
end
