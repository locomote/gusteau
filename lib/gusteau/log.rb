require 'inform'

module Gusteau
  module Log
    def log(msg, opts={})
      info "%{prompt}#{msg}", opts.merge(:prompt => prompt)
      if block_given?
        indent
        start_time = Time.now
        yield.tap do
          unindent
          Inform.info "%{prompt}DONE (in #{'%0.2f' % (Time.now - start_time)}s)", :prompt => prompt
        end
      else
        puts "\n"
      end
    end

    def log_error(msg, opts={})
      Inform.error "%{prompt}#{msg}", opts.merge(:prompt => prompt)
    end

    def info(str, opts={})
      Inform.info str, opts
    end

    private

    def timestamp
      Time.now.strftime('%Y-%m-%dT%H:%M:%S')
    end

    def indent
      @level = (@level || 0) + 1
    end

    def unindent
      @level = (@level || 0) - 1
    end

    def prompt
      "[#{timestamp}] GUSTEAU: #{'  ' * (@level || 0)}"
    end
  end
end
