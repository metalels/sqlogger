# desc "Explaining what the task does"

task :sqlogger => "sqlogger:install"
namespace :sqlogger do
  desc "install sqlogger to a rails project."
  task :install do
    conf_path = Rails.root.join("config").join("sqlogger.yml")
    if File.exist? conf_path
      puts "Sqlogger has already installed."
      puts "For more details, see your config/sqlogger.yml file."
    else
      conf_default_body = <<-EOS
## ignore_payload_names
##   set to not logging selected payloads.
ignore_payload_names: [SCHEMA, EXPLAIN]

## ignore_sql_commands
##   set to not logging selected payloads.
ignore_sql_commands: [begin, rollback, SAVEPOINT, RELEASE]

## post_targets: set to logging target. e.g. [elasticsearch, echo]
##   (current only support echo and elasticsearch)
post_targets: []

## elasticsearch options
##   only uses set to logging to elasticsearch on post_targets.
elasticsearch:
  url: "http://localhost:9200/"
  index_name: "sqlogger-metrics"
  check_name: "metrics-query"
  post_keys: [server, status, pid, sql, binds, dulation, payload]
  critical_dulation: 10.0
  warning_dulation: 5.0
  ssl_verify_none: false
  post_timeout: 1.0
  open_timeout: 1.0
  read_timeout: 1.0
  debug: false

## echo options (sysmem echo to file)
##   only uses set to logging to echo on post_targets.
echo:
  file: "log/sqlogger.log"
  debug: false
      EOS
      File.write(conf_path, conf_default_body)
      puts "Sqlogger has been successfully installed."
      puts "For more details, see your config/sqlogger.yml file."
    end
  end
end
