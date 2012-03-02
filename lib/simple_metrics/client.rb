# encoding: utf-8
require "socket"

module SimpleMetrics

  class Client
    VERSION = "0.0.1"
    
    def initialize(host, port = 8125)
      @host, @port = host, port
    end

    # send relative value
    def increment(stat, sample_rate = 1)
      count(stat, 1, sample_rate)
    end

    # send relative value
    def decrement(stat, sample_rate = 1)
      count(stat, -1, sample_rate)
    end

    # send relative value
    def count(stat, count, sample_rate = 1)
      send_data( stat, count, 'c', sample_rate)
    end

    # send absolute value
    # TODO: check if this is actually supported by Statsd server
    def gauge(stat, value)
      send_data(stat, value, 'g')
    end

    # Sends a timing (in ms) (glork)
    def timing(stat, ms, sample_rate = 1)
      send_data(stat, ms, 'ms', sample_rate)
    end

    # Sends a timing (in ms) block based
    def time(stat, sample_rate = 1, &block)
      start = Time.now
      result = block.call
      timing(stat, ((Time.now - start) * 1000).round, sample_rate)
      result
    end

    private

    def sampled(sample_rate, &block)
      if sample_rate < 1
        block.call if rand <= sample_rate
      else
        block.call
      end
    end

    def send_data(stat, delta, type, sample_rate = 1)
      sampled(sample_rate) do
        data = "#{stat}:#{delta}|#{type}" # TODO: check stat is valid
        data << "|@#{sample_rate}" if sample_rate < 1
        send_to_socket(data)
      end
    end

    def send_to_socket(data)
      logger.debug "SimpleMetrics Client send: #{data}"
      socket.send(data, 0, @host, @port)
    rescue Exception => e
      puts e.backtrace
      logger.error "SimpleMetrics Client error: #{e}"
    end

    def socket
      @socket ||= UDPSocket.new 
    end

    def logger
      @logger ||= SimpleMetrics.logger
    end

  end

end