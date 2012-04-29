# encoding: utf-8
require "spec_helper"
require "simple_metrics/app"

module SimpleMetrics

  describe "Sinatra App" do

    before do
      InstrumentRepository.truncate_collections
    end

    describe "GET /api/instruments" do

      before do
        instrument = Instrument.new(:name => "test")
        InstrumentRepository.save(instrument)
      end

      it "returns JSON with all instruments" do
        get "/api/instruments"
        last_response.should be_ok
        body = JSON.parse(last_response.body)
        body.should have(1).instrument
        body.last["name"].should == "test"
      end

    end # describe "GET /api/instruments" do

    describe "POST /api/instruments" do

      it "creates a new instrument" do
        post "/api/instruments", { :name => "test", :metrics => [ { :name => "metric1" } ] }.to_json
        last_response.status.should == 201
        results = InstrumentRepository.find_all

        results.should have(1).instrument
        instrument = results.first

        instrument.name.should == "test"
        instrument.metrics.first[:name] == "metric1"
      end

    end # describe "POST /api/instruments" do

    describe "PUT /api/instruments/:id" do

      before do
        InstrumentRepository.save(Instrument.new(:name => "test", :metrics => [ { :name => "metric1" } ]))
        @instrument = InstrumentRepository.find_one_by_name("test")
      end

      it "updates the instrument" do
        put "/api/instruments/#{@instrument.id}", { :name => "test2", :metrics => [ { :name => "metric2" } ] }.to_json
        last_response.status.should == 201
        
        results = InstrumentRepository.find_all
        results.should have(1).instrument
        instrument = results.first
        instrument.name.should == "test2"
        instrument.metrics.first[:name] == "metric2"
      end

    end # describe "PUT /api/instruments/:id" do

    def app
      SimpleMetrics::App
    end

  end # describe "Sinatra App"

end
