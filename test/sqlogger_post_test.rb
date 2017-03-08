require 'test_helper'

class Sqlogger::PostTest < ActiveSupport::TestCase
  setup do
    @org_logger = Rails.logger
    Rails.logger = LogMock.new
  end

  teardown do
    Rails.logger = @org_logger
  end

  test "call elasticsearch post from Base::logger pass action" do 
    stub_request(
      :any,
      /http:\/\/localhost:9200\/.*/
    ).with(
      :body => /.*/,
      :headers => {
        'Accept'=>'*/*',
        'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'Content-Type'=>'application/json; charset=utf-8',
        'User-Agent'=>'Ruby'
      }
    ).to_return(
      :status => 200,
      :body => "elastic ok",
      :headers => {
        'Content-Length' => 10
      }
    )
    Rails.application.config.sqlogger.post_targets = [:elasticsearch]
    Rails.application.config.sqlogger.elasticsearch.debug = true
    Sqlogger::Base::logger(
      sql: "INSERT INTO test VALUES ?,?",
      binds: "string: 'hoge', bool: true",
      name: "Test",
      dulation: 0.05
    )
    log = nil
    200.times do
      break if log = Rails.logger.output.pop
      sleep(0.005)
    end
    Rails.application.config.sqlogger.elasticsearch.debug = false
    Rails.application.config.sqlogger.post_targets = []
    assert_equal log, "info:Elasticsearch posted 200."
  end
  
  test "call echo post from Base::logger pass action" do 
    outlog = "test/dummy/log/sqlogger.log"
    File.delete outlog if File.exist? outlog
    Rails.application.config.sqlogger.post_targets = [:echo]
    Rails.application.config.sqlogger.echo.file = outlog
    Rails.application.config.sqlogger.echo.debug = true
    Sqlogger::Base::logger(
      sql: "INSERT INTO test VALUES ?,?",
      binds: "string: 'hoge', bool: true",
      name: "Test",
      dulation: 0.05
    )
    100.times do
      break if File.exist?(outlog)
      sleep(0.05)
    end
    log = nil
    200.times do
      break if log = Rails.logger.output.pop
      sleep(0.005)
    end
    Rails.application.config.sqlogger.echo.debug = false
    Rails.application.config.sqlogger.post_targets = []
    assert_equal log, "info:Echo ok."
    assert_equal File.exist?(outlog), true
    output = File.read(outlog).gsub(
      /Time: \d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} .\d{4}\n/,
      "Time: mutable\n"
    )
    expected_val = <<-EOS
PID: #{Process.pid()}
Time: mutable
SQL: INSERT INTO test VALUES ?,?
BINDS: string: 'hoge', bool: true
NAME: Test
DULATION: 0.05ms
----------
    EOS
    assert_equal output, expected_val
  end

  
  test "call echo post with dummy User creation" do 
    outlog = "test/dummy/log/sqlogger.log"
    File.delete outlog if File.exist? outlog
    100.times do
      break unless File.exist?(outlog)
      sleep 0.05
    end
    Rails.application.config.sqlogger.post_targets = [:echo]
    Rails.application.config.sqlogger.ignore_sql_commands = %w(SELECT UPDATE CREATE RELEASE SAVEPOINT)
    Rails.application.config.sqlogger.echo.file = outlog
    Rails.application.config.sqlogger.echo.debug = true
    User.create(name: "test sqlogger")
    100.times do
      break if File.exist?(outlog)
      sleep 0.05
    end
    log = nil
    200.times do
      break if log = Rails.logger.output.pop
      sleep 0.005
    end
    Rails.application.config.sqlogger.echo.debug = false
    Rails.application.config.sqlogger.post_targets = []
    assert_equal File.exist?(outlog), true
    assert_equal log, "info:Echo ok."
    output = File.read(outlog).gsub(
      /Time: \d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} .\d{4}\n/,
      "Time: mutable\n"
    ).gsub(
      /BINDS: \[\['name', 'test sqlogger'\], .*\]\]\n/,
      "BINDS: \[\['name', 'test sqlogger'\], mutable\n"
    ).gsub(
      /DULATION: \d\.\dms/,
      "DULATION: mutable ms"
    )

    expected_val = <<-EOS
PID: #{Process.pid()}
Time: mutable
SQL: INSERT INTO 'users' ('name', 'created_at', 'updated_at') VALUES (?, ?, ?)
BINDS: [['name', 'test sqlogger'], mutable
DULATION: mutable ms
NAME: SQL
----------
    EOS
    assert_equal output, expected_val
  end

  test "call echo post with dummy Image(binary) creation" do
    image = "sqlogger_elasticsearch.png"
    outlog = "test/dummy/log/sqlogger.log"
    File.delete outlog if File.exist? outlog
    100.times do
      break unless File.exist?(outlog)
      sleep 0.05
    end
    Rails.application.config.sqlogger.post_targets = [:echo]
    Rails.application.config.sqlogger.ignore_sql_commands = %w(SELECT UPDATE CREATE RELEASE SAVEPOINT)
    Rails.application.config.sqlogger.echo.file = outlog
    Rails.application.config.sqlogger.echo.debug = true
    Image.create(
      name: image,
      body: File.read(image)
    )
    100.times do
      break if File.exist?(outlog)
      sleep 0.05
    end
    log = nil
    200.times do
      break if log = Rails.logger.output.pop
      sleep 0.005
    end
    Rails.application.config.sqlogger.echo.debug = false
    Rails.application.config.sqlogger.post_targets = []
    assert_equal File.exist?(outlog), true
    assert_equal log, "info:Echo ok."
    output = File.read(outlog).gsub(
      /Time: \d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} .\d{4}\n/,
      "Time: mutable\n"
    ).gsub(
      /BINDS: \[\['name', 'sqlogger_elasticsearch.png'\], \['body', '<33856 bytes of binary data>'\], .*\]\]\n/,
      "BINDS: \[\['name', 'sqlogger_elasticsearch.png'\], \['body', '<33856 bytes of binary data>'\], mutable\n"
    ).gsub(
      /DULATION: \d\.\dms/,
      "DULATION: mutable ms"
    )

    expected_val = <<-EOS
PID: #{Process.pid()}
Time: mutable
SQL: INSERT INTO 'images' ('name', 'body', 'created_at', 'updated_at') VALUES (?, ?, ?, ?)
BINDS: [['name', 'sqlogger_elasticsearch.png'], ['body', '<33856 bytes of binary data>'], mutable
DULATION: mutable ms
NAME: SQL
----------
    EOS
    assert_equal output, expected_val
  end
end
