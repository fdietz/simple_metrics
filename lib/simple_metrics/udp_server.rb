# encoding: utf-8
require "eventmachine"

if defined? Encoding
  Encoding.default_external = Encoding::UTF_8
end

module SimpleMetrics

  module ClientHandler

    @@data = []

    class << self
      def get_and_clear_data
        data = @@data.dup
        @@data = []
        data
      end
    end

    def post_init
      SimpleMetrics.logger.info "ClientHandler entering post_init"
    end

    def receive_data(data)
      SimpleMetrics.logger.debug "received_data: #{data.inspect}"
      @@data << data
    end
  end

  class UDPServer

    def start
      SimpleMetrics.logger.info "SERVER: starting up on #{host}:#{port}..."

      trap('TERM') { stop }
      trap('INT')  { stop }

      DataPointRepository.ensure_collections_exist

      EM.run do
        EM.open_datagram_socket(host, port, SimpleMetrics::ClientHandler) do |con|
          EventMachine::add_periodic_timer(flush_interval) do
            SimpleMetrics.logger.debug "SERVER: period timer triggered after #{flush_interval} seconds"

            EM.defer { Bucket.flush_raw(ClientHandler.get_and_clear_data) } 
          end
        end
      end
    end

    def stop
      SimpleMetrics.logger.info "EventMachine stop"
      EM.stop
    end
    
    def to_s
      "#{host}:#{port}"
    end

    private

    def host
      config['host'] || 'localhost'
    end

    def port 
      config['port'] || 8125
    end

    def flush_interval
      config['flush_interval'] || 10
    end

    def config
      SimpleMetrics.config.server
    end

  end
end
