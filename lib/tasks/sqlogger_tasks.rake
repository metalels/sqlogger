# desc "Explaining what the task does"

task :sqlogger => "sqlogger:install"
namespace :sqlogger do
  desc "install sqlogger to a rails project."
  task :install do
    conf_path = Rails.root.join("config").join("initializers").join("sqlogger.rb")
    if File.exist? conf_path
      puts "Sqlogger has already installed."
      puts "For more details, see your config/initializers/sqlogger.rb file."
    else
      conf_default_body = <<-EOS
## ignore_payload_names
##   set to not logging selected payloads.
#Rails.application.config.sqlogger.ignore_payload_names = %w(SCHEMA EXPLAIN)

## ignore_sql_commands
##   set to not logging selected payloads.
#Rails.application.config.sqlogger.ignore_sql_commands = %w(begin rollback SAVEPOINT RELEASE)

## post_targets: set to logging target. e.g. %w(elasticsearch echo)
##   (current only support echo and elasticsearch)
#Rails.application.config.sqlogger.post_targets = %w()

## elasticsearch options
##   only uses set to logging to elasticsearch on post_targets.
#Rails.application.config.sqlogger.elasticsearch.url = "http://localhost:9200/"
#Rails.application.config.sqlogger.elasticsearch.index_name = "sqlogger-metrics"
#Rails.application.config.sqlogger.elasticsearch.check_name = "metrics-query"
#Rails.application.config.sqlogger.elasticsearch.post_keys = %w(server status pid sql binds dulation payload)
#Rails.application.config.sqlogger.elasticsearch.critical_dulation = 10.0
#Rails.application.config.sqlogger.elasticsearch.warning_dulation = 5.0
#Rails.application.config.sqlogger.elasticsearch.ssl_verify_none = false
#Rails.application.config.sqlogger.elasticsearch.post_timeout = 1.0
#Rails.application.config.sqlogger.elasticsearch.open_timeout = 1.0
#Rails.application.config.sqlogger.elasticsearch.read_timeout = 1.0
#Rails.application.config.sqlogger.elasticsearch.debug = false

## echo options (sysmem echo to file)
##   only uses set to logging to echo on post_targets.
#Rails.application.config.sqlogger.echo.file = "log/sqlogger.log"
#Rails.application.config.sqlogger.echo.debug = false
      EOS
      File.write(conf_path, conf_default_body)
      puts "Sqlogger has been successfully installed."
      puts "For more details, see your config/initializers/sqlogger.rb file."
    end
  end
end
