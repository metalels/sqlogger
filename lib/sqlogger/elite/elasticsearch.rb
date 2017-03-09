module Sqlogger
  module Elite
    module Elasticsearch
      require 'net/http'
      require 'uri'
      class << self 

        def post opts={}
          return unless opts[:sql]
          post_data = generate_postdata_with opts
          post_keys = generate_postkeys

          post_data.reject! do |k, _|
            !post_keys.include? k
          end
          random_hash = Digest::MD5.hexdigest "#{post_data["key"]}#{Time.now.to_i}#{rand(999)}"

          https_post "#{url}#{random_hash}", post_data
        rescue => ex
          if config.debug
            Rails.logger.error ex.message
          end
        end

        private

        def config
          Sqlogger::Base.config.elasticsearch
        end

        def https_post full_url, post_data
          Timeout.timeout(config.post_timeout) do
            uri = URI.parse full_url
            http = Net::HTTP.new uri.host, uri.port
            http.use_ssl = true if base_url =~ /\Ahttps/
            http.verify_mode = OpenSSL::SSL::VERIFY_NONE if config.ssl_verify_none
            http.open_timeout = config.open_timeout
            http.read_timeout = config.read_timeout

            request = Net::HTTP::Post.new(
              uri.path,
              "content-type" => "application/json; charset=utf-8"
            )
            request.body = JSON.dump post_data
            response = http.request request
            if config.debug
              Rails.logger.info "Elasticsearch posted #{response.code}."
            end
            if response.code.to_i/10 != 20
              Rails.logger.error "Elasticsearch posting with failure #{response.code}."
            end
          end
        end

        def generate_postkeys
          config.post_keys + %w(check_name key @timestamp)
        end

        def generate_postdata_with opts
          hostname = predictive_hostname
          dulation = opts[:dulation] || 0.00
          key = "#{hostname}.queries.#{opts[:sql].split.first}"

          {
            "@timestamp" => DateTime.now.to_s,
            "pid" => Process.pid(),
            "status" => status_determined_from(dulation),
            "server" => hostname,
            "check_name" => check_name,
            "key" => key,
            "sql" => opts[:sql],
            "binds" => opts[:binds],
            "dulation" => dulation,
            "payload" => opts[:name]
          }
        end

        def predictive_hostname
          hostname = `hostname`.strip
          hostname.empty? ? "CANTGET" : hostname
        end

        def status_determined_from dulation
          crit_dul = config.critical_dulation
          warn_dul = config.warning_dulation
          dulation > crit_dul ? 2 : dulation > warn_dul ? 1 : 0
        end

        def check_name
          config.check_name
        end

        def base_url
          config.url
        end

        def url
          index_name = config.index_name
          "#{base_url}#{"/" unless base_url.end_with? '/'}#{index_name}/#{check_name}/"
        end

      end
    end
  end
end
