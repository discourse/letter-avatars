require 'rack/utils'
require 'letter_avatar'

class LetterAvatarApp
  def self.call(env)
    unless env['REQUEST_METHOD'] == 'GET'
      return [405, [['Content-Type', 'text/plain']], ["Only GET requests are supported"]]
    end

    unless env['PATH_INFO'] =~ %r{^/letter/([a-zA-Z])$}
      return [404, [['Content-Type', 'text/plain']], ["Resource not found"]]
    end

    letter = $1.upcase
    params = Rack::Utils.parse_query(env['QUERY_STRING'])

    r = params.fetch('r', 0).to_i
    g = params.fetch('g', 0).to_i
    b = params.fetch('b', 0).to_i

    size = params.fetch('size', 50).to_i

    return [200, [['Content-Type', 'image/png']], [LetterAvatar.generate(letter, size, r, g, b)]]
  end
end
