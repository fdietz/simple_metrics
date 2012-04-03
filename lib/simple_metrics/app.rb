require "sinatra"
require "erubis"
require "json"

if defined? Encoding
  Encoding.default_external = Encoding::UTF_8
end

module SimpleMetrics
  class App < Sinatra::Base

    set :views, ::File.expand_path('../views', __FILE__)  
    set :public_folder, File.expand_path('../public', __FILE__)

    helpers do
      def graph_title(time)
        case time
        when "minute"
          "Minute"
        when "hour"
          "Hour"
        when "day"
          "Day"
        when "week"
          "Week"
        end
      end
    end

    get "/api/metrics" do
      content_type :json
      metrics = SimpleMetrics::MetricRepository.find_all
      metrics.inject([]) { |result, m| result << m.attributes }.to_json
    end

    get "/api/metrics/:id" do
      content_type :json
      metric = SimpleMetrics::MetricRepository.find_one(to_bson_id(params[:id]))
      metric.attributes.to_json
    end

    get "/api/graph" do
      content_type :json
      from    = (params[:from]  || Time.now).to_i
      time    = params[:time]   || 'minute'
      targets = params[:targets]
      data_points = prepare_data_points(from, time, *targets)
      data_points.to_json
    end

    get "/*" do
      erb :index
    end

    # get "/metrics" do
    #   erb :index
    # end

    # get "/metrics/:id" do
    #   erb :index
    # end

    # get "/metric" do
    #   @from = (params[:from]  || Time.now).to_i
    #   erb :show
    # end

    # get "/graph" do
    #   @from    = (params[:from]  || Time.now).to_i
    #   @time    = params[:time]   || 'minute'
    #   @targets = params[:target]
    #   @data_points = prepare_data_points(@from, @time, *@targets)
    #   @series = @data_points
    #   erb :graph, :layout => false
    # end

    private

    # params[:id]
    def to_bson_id(id) 
      BSON::ObjectId.from_string(id) 
    end 

    def prepare_data_points(from, time, *targets)
      to = from - time_range(time)
      result = SimpleMetrics::Graph.query_all(bucket(time), to, from, *targets)
      result.map do |data_point|
        { :name => data_point.first, :data => data_point.last.map { |p| { :x => p[:ts], :y => p[:value] || 0 } } }
      end
    end

    def one_minute
      60
    end

    def one_hour
      one_minute * 60
    end

    def one_day
      one_hour * 24
    end

    def one_week
      one_day * 7
    end

    def time_range(time)
      case time
      when 'minute'
        5*one_minute
      when 'hour'
        one_hour
      when 'day'
        one_day
      when 'week'
        one_week
      else 
        raise "Unknown time param: #{time}"
      end
    end

    def bucket(time)
      case time
      when 'minute'
        SimpleMetrics::Bucket[0]
      when 'hour'
        SimpleMetrics::Bucket[1]
      when 'day'
        SimpleMetrics::Bucket[2]
      when 'week'
        SimpleMetrics::Bucket[3]
      end
    end
  end
end
