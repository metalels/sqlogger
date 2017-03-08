module Sqlogger
  module Monkey
    module IncludeActiveRecordLogSubscriber
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
          casted_params = sqlogger_type_casted_binds payload[:binds], payload[:type_casted_binds]
          binds = "  " + payload[:binds].zip(casted_params).map { |attr, value|
            sqlogger_render_bind(attr, value)
          }.inspect
        end
        Sqlogger::Base::logger(
          sql: payload[:sql],
          binds: binds,
          dulation: event.duration.round(1),
          name: "#{"CACHE " if payload[:cached]}#{payload[:name]}"
        )
      end
      
      private

      # for support under rails 5.1.0
      def sqlogger_type_casted_binds(binds, casted_binds)
        casted_binds || binds.map do |attr|
          ActiveRecord::Base.connection.type_cast attr.value_for_database
        end
      end

      def sqlogger_render_bind(attr, type_casted_value)
        value = if attr.type.binary? && attr.value
                  "<#{attr.value_for_database.to_s.bytesize} bytes of binary data>"
                else
                  type_casted_value
                end

        [attr.name, value]
      end
    end
  end
end
