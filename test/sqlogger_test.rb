require 'test_helper'

class Sqlogger::Test < ActiveSupport::TestCase
  test "truth" do
    assert_kind_of Module, Sqlogger
    assert_kind_of Module, Sqlogger::Base
    assert_kind_of Module, Sqlogger::Monkey
    assert_kind_of Module, Sqlogger::Monkey::ActiveRecord
    assert_kind_of Module, Sqlogger::Monkey::ActiveRecord::ReplaceLogSubscriber
    assert_kind_of Module, Sqlogger::Elite
    assert_kind_of Module, Sqlogger::Elite::Elasticsearch
    assert_kind_of Module, Sqlogger::Elite::Echo
    assert_kind_of Class, Sqlogger::Railtie
  end

  test "call Sqlogger::Base::logger" do
    assert_nil Sqlogger::Base::logger()
  end
end
