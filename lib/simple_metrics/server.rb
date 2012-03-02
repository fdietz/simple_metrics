# encoding: utf-8
require "eventmachine"

module SimpleMetrics

  module ClientHandler

    @@data_points = []

    class << self
      def get_and_clear_data_points
        data_points = @@data_points.dup
        @@data_points = []
        data_points
      end
    end

    def data_points
      @@data_points
    end

    def post_init
      SimpleMetrics.logger.info "ClientHandler entering post_init"
    end

    def receive_data(data)
      SimpleMetrics.logger.debug "received_data: #{data.inspect}"

      @@data_points ||= []
      @@data_points << DataPoint.parse(data)
    rescue DataPoint::ParserError => e
      SimpleMetrics.logger.debug "Invalid Data skipped: #{data}"
    end
  end

  class Server

    attr_reader :db, :connection

    def start
      SimpleMetrics.logger.info "SERVER: starting up on #{SimpleMetrics.config[:host]}:#{SimpleMetrics.config[:port]}..."

      Mongo.ensure_collections_exist

      EM.run do
        EM.open_datagram_socket(SimpleMetrics.config[:host], SimpleMetrics.config[:port], SimpleMetrics::ClientHandler) do |con|
          EventMachine::add_periodic_timer(SimpleMetrics.config[:flush_interval]) do
            SimpleMetrics.logger.debug "SERVER: period timer triggered after #{SimpleMetrics.config[:flush_interval]} seconds"

            EM.defer { Bucket.flush_data_points(ClientHandler.get_and_clear_data_points) } 
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
