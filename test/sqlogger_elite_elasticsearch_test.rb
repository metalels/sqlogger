require 'test_helper'

class Sqlogger::Elite::Elasticsearch::Test < ActiveSupport::TestCase
  setup do
    @org_logger = Rails.logger
    Rails.logger = LogMock.new
  end

  teardown do
    Rails.logger = @org_logger
  end

  (200..206).to_a.each do |code|
    test "call post(success #{code})" do
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
        :status => code,
        :body => "elastic ok",
        :headers => {
          'Content-Length' => 10
        }
      )
      Rails.application.config.sqlogger.elasticsearch.debug = true
      Sqlogger::Elite::Elasticsearch.post(
        sql: "INSERT INTO test VALUES ?,?",
        binds: "string: 'hoge', bool: true",
        name: "Test",
        dulation: 0.05
      )
      log = Rails.logger.output.pop
      assert_equal log, "info:Elasticsearch posted #{code}."
      Rails.application.config.sqlogger.elasticsearch.debug = false
    end
  end

  [
    100, 101,
    *(300..305).to_a, 307,
    *(400..417).to_a,
    *(500..505).to_a
  ].each do |code|
    test "call post(fail #{code})" do
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
        :status => code,
        :body => "elastic fail",
        :headers => {
          'Content-Length' => 10
        }
      )
      Sqlogger::Elite::Elasticsearch.post(
        sql: "INSERT INTO test VALUES ?,?",
        binds: "string: 'hoge', bool: true",
        name: "Test",
        dulation: 0.05
      )
      assert_equal Rails.logger.output.pop , "error:Elasticsearch posting with failure #{code}."
    end
  end

  test "call post(fail with unhandle error)" do
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
    ).to_raise(
      StandardError.new("some error.")
    )
    Rails.application.config.sqlogger.elasticsearch.debug = true
    Sqlogger::Elite::Elasticsearch.post(
      sql: "INSERT INTO test VALUES ?,?",
      binds: "string: 'hoge', bool: true",
      name: "Test",
      dulation: 0.05
    )
    assert_equal Rails.logger.output.pop , "error:some error."
    Rails.application.config.sqlogger.elasticsearch.debug = false
  end
end
