require 'test_helper'

class Sqlogger::Test < ActiveSupport::TestCase
  test "truth" do
    assert_kind_of Module, Sqlogger
    assert_kind_of Module, Sqlogger::Base
    assert_kind_of Module, Sqlogger::Monkey
    assert_kind_of Module, Sqlogger::Monkey::IncludeActiveRecordLogSubscriber
    assert_kind_of Module, Sqlogger::Elite
    assert_kind_of Module, Sqlogger::Elite::Elasticsearch
    assert_kind_of Module, Sqlogger::Elite::Echo
    assert_kind_of Class, Sqlogger::Railtie
  end

  test "call Sqlogger::Base::logger" do
    assert_nil Sqlogger::Base::logger()
  end

  test "auto load config" do
    assert_equal 2.0, Rails.application.config.sqlogger.elasticsearch.post_timeout
    assert_equal 2.0, Rails.application.config.sqlogger.elasticsearch.open_timeout
    assert_equal 2.0, Rails.application.config.sqlogger.elasticsearch.read_timeout
    assert_equal "nothing", Rails.application.config.sqlogger.echo.ext
  end
end
