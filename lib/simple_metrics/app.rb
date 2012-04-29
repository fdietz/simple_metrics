require "sinatra"
require "erubis"
require "json"

# ENV['RACK_ENV'] = 'development'

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
      puts data_points.to_json
      data_points.to_json
    end

    get "/api/dashboards" do
      content_type :json

      dashboards = SimpleMetrics::DashboardRepository.find_all
      dashboards.inject([]) { |result, m| result << m.attributes }.to_json
    end

    get "/api/dashboards/:id" do
      content_type :json

      dashboard = SimpleMetrics::DashboardRepository.find_one(params[:id])
      dashboard.attributes.to_json
    end

    get "/api/instruments" do
      content_type :json

      instruments = SimpleMetrics::InstrumentRepository.find_all
      instruments.inject([]) { |result, m| result << m.attributes }.to_json
    end

    get "/api/instruments/:id" do
      content_type :json

      instrument = SimpleMetrics::InstrumentRepository.find_one(params[:id])
      instrument.attributes.to_json
    end

    put "/api/instruments/:id" do
      content_type :json

      attributes = JSON.parse(request.body.read.to_s).symbolize_keys
      instrument = SimpleMetrics::InstrumentRepository.find_one(params[:id])
      instrument.metrics = attributes[:metrics]
      instrument.name = attributes[:name]
      SimpleMetrics::InstrumentRepository.update(instrument)
      201
    end

    post "/api/instruments" do
      content_type :json

      attributes = JSON.parse(request.body.read.to_s).symbolize_keys
      SimpleMetrics::InstrumentRepository.save(Instrument.new(attributes))
      201
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
