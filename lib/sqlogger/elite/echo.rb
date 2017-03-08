module Sqlogger
  module Elite
    module Echo
      require "open3"

      def self.post(opts={})
        return unless opts[:sql]
        echo_file = Rails.application.config.sqlogger.echo.file
        debug = Rails.application.config.sqlogger.echo.debug
        information = information_string_of opts

        echo_result = Open3.capture3 "echo \"#{information}\" >> #{echo_file}"
        if debug
          if echo_result.last.exitstatus == 0
            Rails.logger.info "Echo ok."
          else
            Rails.logger.error "Echo fail. (#{echo_result.second.strip})"
          end
        end
      rescue => ex
        if debug
          Rails.logger.error ex.message
        end
      end

      private

      def self.information_string_of(opts={})
        info = opts.map do |k,v|
          "#{k.to_s.upcase}: #{v}#{"ms" if k == :dulation}"
        end
        info.unshift "Time: #{Time.now}"
        info.unshift "PID: #{Process.pid()}"
        info.push "" << "-" * 10
        info.join("\n").gsub('"',"'")
      end

    end
  end
end
