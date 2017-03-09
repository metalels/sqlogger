require "sqlogger/elite/elasticsearch"
require "sqlogger/elite/echo"

module Sqlogger
  module Elite

    class << self
      def post_with opts
        Thread.start do
          unique_post_target.each do |post_target|
            case post_target
            when "echo"
              Sqlogger::Elite::Echo::post opts
            when "elasticsearch"
              Sqlogger::Elite::Elasticsearch.post opts
            end
          end
        end
      end

      private

      def unique_post_target
        Sqlogger::Base.config.post_targets.map(&:to_s).uniq
      end
    end

  end
end
