require 'rails'

module Sqlogger
  class Railtie < Rails::Railtie
    initializer "sqlogger_railtie.configure_rails_initialization" do
      ActiveSupport.on_load :active_record do
        require 'sqlogger/monkey/include_active_record_log_subscriber'
        ActiveRecord::LogSubscriber.send :include, Sqlogger::Monkey::IncludeActiveRecordLogSubscriber
      end
    end

    config.sqlogger = ActiveSupport::OrderedOptions.new
    config.sqlogger.elasticsearch = ActiveSupport::OrderedOptions.new
    config.sqlogger.echo = ActiveSupport::OrderedOptions.new

    #define default values
    config.sqlogger.ignore_payload_names = %w(SCHEMA EXPLAIN)
    config.sqlogger.ignore_sql_commands = %w(begin rollback SAVEPOINT RELEASE)
    config.sqlogger.post_targets = []

    config.sqlogger.elasticsearch.check_name = "metrics-query"
    config.sqlogger.elasticsearch.url = "http://localhost:9200/"
    config.sqlogger.elasticsearch.index_name = "sqlogger-metrics"
    config.sqlogger.elasticsearch.post_keys = %w(server status pid sql binds dulation payload)
    config.sqlogger.elasticsearch.critical_dulation = 10.0
    config.sqlogger.elasticsearch.warning_dulation = 5.0
    config.sqlogger.elasticsearch.ssl_verify_none = false
    config.sqlogger.elasticsearch.post_timeout = 1.0
    config.sqlogger.elasticsearch.open_timeout = 1.0
    config.sqlogger.elasticsearch.read_timeout = 1.0
    config.sqlogger.elasticsearch.debug = false

    config.sqlogger.echo.file = "log/sqlogger.log"
    config.sqlogger.echo.debug = false

    rake_tasks do
      load "tasks/sqlogger_tasks.rake"
    end
  end
end
