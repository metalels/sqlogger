module Sqlogger
  module Elite
    module Echo
      require "open3"

      def self.post(opts={})
        return unless opts[:sql]
        echo_file = Rails.application.config.sqlogger.echo.file
        debug = Rails.application.config.sqlogger.echo.debug

        info = opts.map do |k,v|
          "#{k.to_s.upcase}: #{v}#{"ms" if k == :dulation}"
        end
        info.unshift "Time: #{Time.now.to_s}"
        info.unshift "PID: #{Process.pid()}"
        info.push "" << "-" * 10
        echo_result = Open3.capture3 "echo \"#{info.join("\n")}\" >> #{echo_file}"
        if debug
          if echo_result.last.exitstatus == 0
            Rails.logger.info "Echo ok."
          else
            Rails.logger.error "Echo fail."
          end
        end
      rescue => ex
        if debug
          Rails.logger.error ex.message
        end
      end
    end
  end
end