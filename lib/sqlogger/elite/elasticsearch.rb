module Sqlogger
  module Elite
    module Elasticsearch
      require 'net/http'
      require 'uri'

      def self.post_data_base
        {
          "@timestamp" => DateTime.now.to_s,
          "pid" => Process.pid()
        }
      end

      def self.check_name
        Rails.application.config.sqlogger.elasticsearch.check_name
      end

      def self.base_url
        Rails.application.config.sqlogger.elasticsearch.url
      end

      def self.url
        index_name = Rails.application.config.sqlogger.elasticsearch.index_name
        "#{base_url}#{"/" unless base_url.end_with?('/')}#{index_name}/#{check_name}/"
      end

      def self.post(opts={})
        return unless opts[:sql]
        sql_action = opts[:sql].split.first
        hostname = `hostname`.strip
        hostname = "CANTGET" if hostname.empty?
        key = "#{hostname}.queries.#{sql_action}"
        post_data = self.post_data_base
        send_keys = Rails.application.config.sqlogger.elasticsearch.post_keys
        dulation = opts[:dulation] || 0.00

        send_keys.push "check_name"
        send_keys.push "key"
        send_keys.push "@timestamp"
        crit_dul = Rails.application.config.sqlogger.elasticsearch.critical_dulation
        warn_dul = Rails.application.config.sqlogger.elasticsearch.warning_dulation
        http_ssl_none_verify = Rails.application.config.sqlogger.elasticsearch.ssl_verify_none
        post_timeout = Rails.application.config.sqlogger.elasticsearch.post_timeout
        http_open_timeout = Rails.application.config.sqlogger.elasticsearch.open_timeout
        http_read_timeout = Rails.application.config.sqlogger.elasticsearch.read_timeout
        debug = Rails.application.config.sqlogger.elasticsearch.debug

        post_data['server'] = hostname
        post_data['check_name'] = check_name
        post_data['status'] = dulation > crit_dul ? 2 : dulation > warn_dul ? 1 : 0
        post_data['key'] = key
        post_data['sql'] = opts[:sql]
        post_data['binds'] = opts[:binds]
        post_data['dulation'] = dulation
        post_data['payload'] = opts[:name]

        post_data.reject! do |k, v|
          !send_keys.include? k
        end

        Timeout.timeout(post_timeout) do
          random_hash = Digest::MD5.hexdigest("#{key}#{Time.now.to_i}#{rand(999)}")
          uri = URI.parse "#{url}#{random_hash}"
          http = Net::HTTP.new uri.host, uri.port
          http.use_ssl = true if base_url =~ /\Ahttps/
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE if http_ssl_none_verify
          http.open_timeout = http_open_timeout
          http.read_timeout = http_read_timeout

          request = Net::HTTP::Post.new(
            uri.path,
            "content-type" => "application/json; charset=utf-8"
          )
          request.body = JSON.dump post_data
          response = http.request request
          if debug
            Rails.logger.info "Elasticsearch posted #{response.code}."
          end
          if response.code.to_i/10 != 20
            Rails.logger.error "Elasticsearch posting with failure #{response.code}."
          end
        end
      rescue => ex
        if debug
          Rails.logger.error ex.message
        end
      end
    end
  end
end
