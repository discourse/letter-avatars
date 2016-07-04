require 'fileutils'
require 'securerandom'

class LetterAvatar
  # CHANGE these values to support more pixel ratios
  FULLSIZE  = 120 * 3
  POINTSIZE = 280

  class << self

    def generate(letter, size, r,g,b, version = 1)
      File.read(generate_path(letter,size, r,g,b, version))
    end

    def generate_path(letter, size, r, g, b, version = 1)
      size = FULLSIZE if size > FULLSIZE

      fullsize_path = temp_path("/#{letter}/#{r}/#{g}_#{b}/full_v#{version}.png")
      resized_path = temp_path("/#{letter}/#{r}/#{g}_#{b}/#{size}_v#{version}.png")

      return resized_path if File.exist?(resized_path)

      temp_file_path = temp_path("/" << SecureRandom.hex << ".png")
      temp_file_dir = File.dirname(temp_file_path)
      FileUtils.mkdir_p(temp_file_dir) unless Dir.exists?(temp_file_dir)

      if File.exist?(fullsize_path)
        FileUtils.cp(fullsize_path, temp_file_path)
      else
        `#{fullsize_command(temp_file_path, letter, r, g, b, version)} 2>/dev/null`
        FileUtils.cp(temp_file_path, temp_file_path + "1")
        FileUtils.mkdir_p(File.dirname(fullsize_path))
        FileUtils.mv(temp_file_path + "1", fullsize_path)
      end

      `#{resize_command(temp_file_path, size)} 2>/dev/null`
      `pngout #{temp_file_path} 2>/dev/null`

      FileUtils.mv(temp_file_path, resized_path)

      resized_path
    end

    def temp_path(path)
      "#{ENV["TEMP_FILE_PATH"] || "/tmp"}#{path}"
    end

    def v1
      @v1 ||= ["Helvetica", Hash.new('-0+26')]
    end

    def v2
      @v2 ||= begin
        offsets = Hash.new('-0+5')
        offsets['0'] = '+6+5'
        offsets['1'] = '+6+5'
        offsets['2'] = '+6+5'
        offsets['6'] = '+4+5'
        offsets['7'] = '+8+5'
        offsets['8'] = '+6+5'
        offsets['9'] = '+4+5'
        offsets['A'] = '+1+5'
        offsets['B'] = '+12+5'
        offsets['C'] = '+8+5'
        offsets['D'] = '+12+5'
        offsets['E'] = '+4+5'
        offsets['F'] = '+6+5'
        offsets['G'] = '+8+5'
        offsets['H'] = '+10+5'
        offsets['I'] = '+12+5'
        offsets['J'] = '+8+5'
        offsets['K'] = '+10+5'
        offsets['L'] = '+8+5'
        offsets['M'] = '+10+5'
        offsets['N'] = '+10+5'
        offsets['O'] = '+8+5'
        offsets['P'] = '+12+5'
        offsets['Q'] = '+8+5'
        offsets['R'] = '+12+5'
        offsets['T'] = '+4+5'
        offsets['U'] = '+10+5'
        offsets['V'] = '+1+5'
        offsets['W'] = '+2+5'
        offsets['X'] = '+2+5'
        offsets['Y'] = '+2+5'
        offsets['Z'] = '+8+5'
        ["Roboto-Medium", offsets]
      end
    end

    def fullsize_command(path, letter, r, g, b, version)
      font, offsets = version == 1 ? v1 : v2

      # NOTE: to debug alignment issues, add these lignes before the path
      # -fill '#00F'
      # -draw "line 0,#{FULLSIZE/2 + FULLSIZE/4} #{FULLSIZE},#{FULLSIZE/2 + FULLSIZE/4}"
      # -draw "line 0,#{FULLSIZE/2} #{FULLSIZE},#{FULLSIZE/2}"
      # -draw "line 0,#{FULLSIZE/4} #{FULLSIZE},#{FULLSIZE/4}"
      # -draw "line #{FULLSIZE/2 + FULLSIZE/4},0 #{FULLSIZE/2 + FULLSIZE/4},#{FULLSIZE}"
      # -draw "line #{FULLSIZE/2},0 #{FULLSIZE/2},#{FULLSIZE}"
      # -draw "line #{FULLSIZE/4},0 #{FULLSIZE/4},#{FULLSIZE}"

      %W{
        convert
        -depth 8
        -dither None
        -colors 128
        -size #{FULLSIZE}x#{FULLSIZE}
        xc:'rgb(#{r},#{g},#{b})'
        -pointsize #{POINTSIZE}
        -fill '#FFFFFFCC'
        -font '#{font}'
        -gravity Center
        -annotate #{offsets[letter]} '#{letter}'
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
