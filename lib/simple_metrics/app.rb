require "sinatra"
require "erubis"
require "json"

module SimpleMetrics
  class App < Sinatra::Base

    set :views, ::File.expand_path('../../../views', __FILE__)  
    set :public_folder, File.expand_path('../../..//public', __FILE__)

    helpers do
    end

    # def initialize(options = {})
    #   super(nil)
    # end

    get "/" do
      @metric_names = SimpleMetrics::Bucket.first.find_all_distinct_names
      erb :index
    end

    get "/graph" do
      @from    = (params[:from]   || Time.now).to_i
      @time    = params[:time]   || 'minute'
      @targets = params[:target] || Array('com.test')
      @data_points = prepare_data_points(@from, @time, *@targets)
      @series = @data_points
      erb :show
    end

    private

    def prepare_data_points(from, time, *targets)
      to = from - time_range(time)
      result = SimpleMetrics::Graph.query_all(bucket, to, from, *targets)
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

    def bucket
      case @time
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
