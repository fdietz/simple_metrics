# encoding: utf-8
require "eventmachine"

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
      SimpleMetrics.logger.info "SERVER: starting up on #{SimpleMetrics.config[:host]}:#{SimpleMetrics.config[:port]}..."

      DataPointRepository.ensure_collections_exist

      EM.run do
        EM.open_datagram_socket(SimpleMetrics.config[:host], SimpleMetrics.config[:port], SimpleMetrics::ClientHandler) do |con|
          EventMachine::add_periodic_timer(SimpleMetrics.config[:flush_interval]) do
            SimpleMetrics.logger.debug "SERVER: period timer triggered after #{SimpleMetrics.config[:flush_interval]} seconds"

            EM.defer { Bucket.flush_raw_data(ClientHandler.get_and_clear_data) } 
          end
        end
      end
    end

    def stop
      SimpleMetrics.logger.info "EventMachine stop"
      EM.stop
    end
    
    def to_s
      "#{SimpleMetrics.config[:host]}:#{SimpleMetrics.config[:port]}"
    end

  end
end
