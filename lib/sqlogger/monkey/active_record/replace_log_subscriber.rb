module Sqlogger
  module Monkey
    module ActiveRecord
      module ReplaceLogSubscriber
        def self.included(base)
          base.class_eval do
            alias_method :sql_without_sqlogger, :sql
            alias_method :sql, :sql_with_sqlogger
          end
        end

        def sql_with_sqlogger(event)
          sql_without_sqlogger(event);

          payload = event.payload
          binds   = ""
          unless (payload[:binds] || []).empty?
            casted_params = payload[:type_casted_binds] || payload[:binds].map { |attr|
              type_cast attr.value_for_database
            }
            binds = "  " + payload[:binds].zip(casted_params).map { |attr, value|
              render_bind(attr, value)
            }.inspect
          end
          Sqlogger::Base::logger(
            sql: payload[:sql],
            binds: binds,
            dulation: event.duration.round(1),
            name: "#{"CACHE " if payload[:cached]}#{payload[:name]}"
          )
        end

        def type_casted_binds

        end
      end
    end
  end
end
