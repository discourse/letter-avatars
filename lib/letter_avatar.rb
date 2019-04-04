require 'fileutils'
require 'securerandom'

class LetterAvatar
  # CHANGE these values to support more pixel ratios
  FULLSIZE  = 120 * 3
  
  class << self

    def generate(letter, size, r, g, b, version = 1)
      File.read(generate_path(letter, size, r, g, b, version))
    end

    def generate_path(letter, size, r, g, b, version = 1, char_type)
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
        `#{fullsize_command(temp_file_path, letter, r, g, b, version, char_type)} 2>/dev/null`
        FileUtils.cp(temp_file_path, temp_file_path + "1")
        FileUtils.mkdir_p(File.dirname(fullsize_path))
        FileUtils.mv(temp_file_path + "1", fullsize_path)
      end

      `#{resize_command(temp_file_path, size)} 2>/dev/null`
      `pngquant #{temp_file_path} -o #{temp_file_path} --quality 10 --force 2>/dev/null`

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
        offsets = Hash.new('-0+0')
        offsets['0'] = '+0+6'
        offsets['1'] = '-4+6'
        offsets['2'] = '+0+5'
        offsets['3'] = '-3+4'
        offsets['4'] = '-3+5'
        offsets['5'] = '-7+5'
        offsets['6'] = '-3+4'
        offsets['7'] = '+4+6'
        offsets['8'] = '+0+4'
        offsets['9'] = '-1+7'
        offsets['A'] = '+0+5'
        offsets['B'] = '+3+6'
        offsets['C'] = '+2+4'
        offsets['D'] = '+4+6'
        offsets['E'] = '-6+6'
        offsets['F'] = '-4+6'
        offsets['G'] = '+3+7'
        offsets['H'] = '+1+7'
        offsets['I'] = '+2+6'
        offsets['J'] = '+6+5'
        offsets['K'] = '-1+5'
        offsets['L'] = '-1+6'
        offsets['M'] = '+1+6'
        offsets['N'] = '+1+6'
        offsets['O'] = '+2+5'
        offsets['P'] = '+3+5'
        offsets['Q'] = '+2+6'
        offsets['R'] = '+3+5'
        offsets['S'] = '-4+6'
        offsets['T'] = '+1+6'
        offsets['U'] = '+2+5'
        offsets['V'] = '+1+6'
        offsets['W'] = '+0+6'
        offsets['X'] = '+0+6'
        offsets['Y'] = '+2+5'
        offsets['Z'] = '+4+6'
        ["Roboto-Medium", offsets]
      end
    end

    def v4
      @v4 ||= begin
        offsets = Hash.new('+2-6')
        ["NotoSansMono-Medium", offsets]
      end
    end

    def fullsize_command(path, letter, r, g, b, version, char_type)
      versions = {1 => v1, 2 => v2, 3 => v2, 4 => v4}
      font, offsets = versions[version]
      pointsize = 280

      if version > 3
        font, pointsize = case char_type
          when 'latin'
            ["NotoSansMono-Medium.ttf", 280] 
          when 'cjk'
            ['NotoSansMonoCJKsc-Regular.otf', 220] 
          when 'arabic'
            ['NotoSansArabic-Medium.ttf', 220] 
          when 'devaganari'
            ['NotoSansDevanagari-Medium.ttf', 220] 
          when 'bengali'
            ['NotoSansBengali-Medium.ttf', 220] 
          when 'javanese'
            ['NotoSansJavanese-Regular.ttf', 220] 
          when 'telugu'
            ['NotoSansTelugu-Regular.ttf', 280] 
          when 'thai'
            ['NotoSansThai-Medium.ttf', 280] 
          when 'hebrew'
            ['NotoSansHebrew-Medium.ttf', 280] 
          when 'armenian'
            ['NotoSansArmenian-Medium.ttf', 280] 
          end
      end

      # NOTE: to debug alignment issues, add these lines before the path
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
        -pointsize #{pointsize}
        -fill '#FFFFFFCC'
        -font '#{font}'
        -gravity Center
        -annotate #{offsets[letter]} '#{letter}'
        '#{path}'
      }.join(' ')
    end

    def resize_command(path, size)
      %W{
        convert
        '#{path}'
        -gravity center
        -background transparent
        -thumbnail #{size}x#{size}
        -extent #{size}x#{size}
        -interpolate Catrom
        -unsharp 2x0.5+0.7+0
        -quality 98
        -dither None
        -colors 128
        '#{path}'
      }.join(' ')
    end

  end
end
