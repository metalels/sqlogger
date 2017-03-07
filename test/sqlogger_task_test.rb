require 'test_helper'

class Sqlogger::TaskTest < ActiveSupport::TestCase
  test "rake task sqlogger installation" do
    gen_file = "test/dummy/config/initializers/sqlogger.rb"
    tpl_file = "test/templates/sqlogger.conf"
    File.delete gen_file if File.exist? gen_file
    100.times do
      break unless File.exist? gen_file
      sleep(0.05)
    end
    assert_equal File.exist?(gen_file), false
    str_io = StringIO.new
    $stdout = str_io
    Rake::Task["sqlogger:install"].invoke
    Rake::Task["sqlogger:install"].reenable
    $stdout = STDOUT
    100.times do
      break if File.exist? gen_file
      sleep(0.05)
    end
    assert_equal File.exist?(gen_file), true
    assert_equal File.read(gen_file), File.read(tpl_file)
    assert_equal str_io.string, "Sqlogger has been successfully installed.\nFor more details, see your config/initializers/sqlogger.rb file.\n"

    File.delete gen_file if File.exist? gen_file
    100.times do
      break unless File.exist? gen_file
      sleep(0.05)
    end
    File.write gen_file, "# test body"
    100.times do
      break if File.exist? gen_file
      sleep(0.05)
    end
    str_io = StringIO.new
    $stdout = str_io
    Rake::Task["sqlogger"].invoke
    Rake::Task["sqlogger"].reenable
    $stdout = STDOUT
    assert_equal File.exist?(gen_file), true
    assert_equal File.read(gen_file), "# test body"
    assert_equal str_io.string, "Sqlogger has already installed.\nFor more details, see your config/initializers/sqlogger.rb file.\n"
  end
end
