require 'rack/utils'
require 'letter_avatar'

class LetterAvatarApp
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

    return [200, {
      'Content-Type' => 'image/png',
      'Cache-Control' => 'max-age=157788000, public'
    }, [LetterAvatar.generate(letter, size, r, g, b)]]
  end

  def self.error(code, msg)
    [code, [['Content-Type', 'text/plain']], [msg]]
  end
end
