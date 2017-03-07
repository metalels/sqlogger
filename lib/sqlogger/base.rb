module Sqlogger
  module Base
    def self.logger(opts={})
      return unless opts[:sql]
      opts[:name] ||= ""
      opts[:sql] = format_sql opts[:sql]
      opts[:binds] = format_sql opts[:binds].strip
      sql_command = opts[:sql].split.first

      ignore_payloads = Rails.application.config.sqlogger.ignore_payload_names
      ignore_commands = Rails.application.config.sqlogger.ignore_sql_commands
      post_targets = Rails.application.config.sqlogger.post_targets

      return if ignore_payloads.include? opts[:name]
      return if ignore_commands.include? sql_command
      if post_targets.include?("elasticsearch") || post_targets.include?(:elasticsearch)
        Thread.start do
          Sqlogger::Elite::Elasticsearch.post opts
        end
      end
      if post_targets.include?("echo") || post_targets.include?(:echo)
        Thread.start do
          Sqlogger::Elite::Echo::post opts
        end
      end
    end

    def self.format_sql(sql="")
      sql.gsub(/(\s+|\n)/, " ")
    end
  end
end
