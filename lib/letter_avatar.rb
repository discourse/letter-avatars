require 'tempfile'

class LetterAvatar
  # CHANGE these values to support more pixel ratios
  FULLSIZE  = 120 * 3
  POINTSIZE = 280

  class << self

    def generate(letter, size, r, g, b)
      size = FULLSIZE if size > FULLSIZE

      file = Tempfile.new('avatar')
      path = file.path + '.png'
      file.unlink

      `#{fullsize_command(path, letter, r, g, b)} 2>/dev/null`
      `#{resize_command(path, size)} 2>/dev/null`
      `pngout #{path} 2>/dev/null`

      File.read(path)
    ensure
      File.unlink(path)
    end

    def fullsize_command(path, letter, r, g, b)
      %W{
        convert
        -dither None
        -colors 128
        -size #{FULLSIZE}x#{FULLSIZE}
        xc:'rgb(#{r},#{g},#{b})'
        -pointsize #{POINTSIZE}
        -fill '#FFFFFFCC'
        -font 'Helvetica'
        -gravity Center
        -annotate -0+26 '#{letter}'
        -depth 8
        -dither None
        -colors 128
        '#{path}'
      }.join(' ')
    end

    def resize_command(path,size)
      %W{
        convert
        '#{path}'
        -gravity center
        -background transparent
        -thumbnail #{size}x#{size}
        -extent #{size}x#{size}
        -interpolate bicubic
        -unsharp 2x0.5+0.7+0
        -quality 98
        -dither None
        -colors 128
        '#{path}'
      }.join(' ')
    end

  end
end
