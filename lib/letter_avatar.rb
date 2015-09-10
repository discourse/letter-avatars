require 'open3'

class LetterAvatar
  # CHANGE these values to support more pixel ratios
  FULLSIZE  = 120 * 3
  POINTSIZE = 280

  class << self

    def generate(letter, size, r, g, b)
      size = FULLSIZE if size > FULLSIZE
      image = nil

      Open3.pipeline_r(
        fullsize_command(letter, r, g, b),
        resize_command(size)
      ) do |stdout_fd, wait_threads|
        stdout_fd.read.tap do
          if wait_threads.any? { |th| th.value.exitstatus != 0 }
            raise RuntimeError,
                  "Image pipeline failed: #{wait_threads.map { |th| th.value }.inspect}"
          end
        end
      end
    end

    def fullsize_command(letter, r, g, b)
      %W{
        convert
        -size #{FULLSIZE}x#{FULLSIZE}
        xc:rgb(#{r},#{g},#{b})
        -pointsize #{POINTSIZE}
        -fill #FFFFFFCC
        -font Helvetica
        -gravity Center
        -annotate -0+26 #{letter}
        -depth 8
        png:-
      }
    end

    def resize_command(size)
      %W{
        convert
        png:-
        -gravity center
        -background transparent
        -thumbnail #{size}x#{size}
        -extent #{size}x#{size}
        -interpolate bicubic
        -unsharp 2x0.5+0.7+0
        -quality 98
        png:-
      }
    end
  end
end
