require 'test_helper'

class Sqlogger::Elite::Echo::Test < ActiveSupport::TestCase
  @@echo_file = "test/dummy/log/sqlogger.log"

  setup do
    File.delete @@echo_file if File.exist? @@echo_file
    @org_logger = Rails.logger
    Rails.logger = LogMock.new
    @so = StringIO.new
    @se = StringIO.new
    $stdout = @so
    $stderr = @se
  end

  teardown do
    $stdout = STDOUT
    $stderr = STDERR
    Rails.logger = @org_logger
  end

  test "call post(fail echo command)" do
    Rails.application.config.sqlogger.echo.debug = true
    Rails.application.config.sqlogger.echo.file = "path/to/not/found"
    Sqlogger::Elite::Echo.post(
      sql: "INSERT INTO test VALUES ?,?",
      binds: "string: 'hoge', bool: true",
      name: "Test",
      dulation: 0.05
    )
    assert_equal Rails.logger.output.pop , "error:Echo fail."
    Rails.application.config.sqlogger.echo.file = "log/sqlogger.log"
    Rails.application.config.sqlogger.echo.debug = false
  end

  test "call post(fail with unhandle error)" do
    Rails.application.config.sqlogger.echo.debug = true
    Rails.application.config.sqlogger.echo.file = @@echo_file
    String.any_instance.stubs(:upcase).raises(StandardError.new("some error."))
    Sqlogger::Elite::Echo.post(
      sql: "INSERT INTO test VALUES ?,?",
      binds: "string: 'hoge', bool: true",
      name: "Test",
      dulation: 0.05
    )
    assert_equal Rails.logger.output.pop , "error:some error."
    Rails.application.config.sqlogger.echo.file = "log/sqlogger.log"
    Rails.application.config.sqlogger.echo.debug = false
  end
end
