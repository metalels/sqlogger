module Sqlogger
  module Base

    class << self 
      def logger opts={}
        return unless opts[:sql]
        opts = format_options opts

        if config.ignore_payload_names.include?(opts[:name]) ||
            config.ignore_sql_commands.include?(sql_command_of opts[:sql])
          return
        end

        Sqlogger::Elite.post_with opts
      end

      def config
        Rails.application.config.sqlogger
      end

      private

      def sql_command_of sql=""
        sql.split.first
      end

      def format_sql sql=""
        sql.gsub(/(\s+|\n)/, " ")
      end

      def format_options opts={}
        opts[:name] ||= ""
        opts[:sql] = format_sql opts[:sql]
        opts[:binds] = format_sql opts[:binds].strip
        opts
      end
    end

  end
end
