module Sqlogger
  module Elite
    class Echo
      require "open3"

      class << self 
        def post opts={}
          return unless opts[:sql]
          echo_file = Sqlogger::Base.config.echo.file
          debug = Sqlogger::Base.config.echo.debug
          information = information_string_of opts

          echo_result = Open3.capture3 "echo \"#{information}\" >> #{echo_file}"
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

        private

        def information_string_of opts={}
          info = opts.map do |k,v|
            "#{k.to_s.upcase}: #{v}#{"ms" if k == :dulation}"
          end
          info.unshift "Time: #{Time.now}"
          info.unshift "PID: #{Process.pid()}"
          info.push "" << "-" * 10
          info.join("\n").tr '"', '\''
        end

      end
    end
  end
end
