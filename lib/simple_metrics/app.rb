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
    end

    get "/api/metrics" do
      content_type :json
      metrics = SimpleMetrics::MetricRepository.find_all
      metrics.inject([]) { |result, m| result << m.attributes }.to_json
    end

    get "/api/metrics/:name" do
      content_type :json
      metric = SimpleMetrics::MetricRepository.find_one_by_name(params[:name])
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

    private

    def prepare_data_points(from, time, *targets)
      bucket = SimpleMetrics::Bucket.for_time(time)
      to = from - SimpleMetrics::Graph.time_range(time)
      SimpleMetrics::Graph.query_all(bucket, to, from, *targets)
    end

  end
end
