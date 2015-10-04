require 'fileutils'
require 'securerandom'

class LetterAvatar
  # CHANGE these values to support more pixel ratios
  FULLSIZE  = 120 * 3
  POINTSIZE = 280

  class << self

    def generate(letter, size, r, g, b, version = 1)

      size = FULLSIZE if size > FULLSIZE

      fullsize_path = temp_path("/#{letter}/#{r}/#{g}_#{b}/full_v#{version}.png")
      resized_path = temp_path("/#{letter}/#{r}/#{g}_#{b}/#{size}_v#{version}.png")

      return File.read(resized_path) if File.exist? resized_path

      temp_file_path = temp_path("/" << SecureRandom.hex << ".png")

      if File.exist? fullsize_path
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
      File.read(resized_path)
    end

    def temp_path(path)
      "#{ENV["TEMP_FILE_PATH"] || "/tmp"}#{path}"
    end

    def fullsize_command(path, letter, r, g, b, version)
      font, offsets = if version == 1
        ["Helvetica", Hash.new('-0+26')]
      else
        offset_hash = Hash.new('-0+0')
        offset_hash['B'] = '+6+0'
        offset_hash['D'] = '+12+0'
        offset_hash['P'] = '+6+0'
        offset_hash['Q'] = '+0-6'
        offset_hash['T'] = '+0+12'
        offset_hash['V'] = '+0+6'
        offset_hash['W'] = '+0+12'
        offset_hash['Y'] = '+0+6'
        offset_hash['7'] = '+6+12'

        ["Roboto-Medium", offset_hash]
      end

      %W{
        convert
        -dither None
        -colors 128
        -size #{FULLSIZE}x#{FULLSIZE}
        xc:'rgb(#{r},#{g},#{b})'
        -pointsize #{POINTSIZE}
        -fill '#FFFFFFCC'
        -font '#{font}'
        -gravity Center
        -annotate #{offsets[letter]} '#{letter}'
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
