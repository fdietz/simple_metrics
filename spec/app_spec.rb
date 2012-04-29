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

      it "should return JSON with instruments" do
        get "/api/instruments"
        last_response.should be_ok
        body = JSON.parse(last_response.body)
        body.should have(1).instrument
        body.last["name"].should == "test"
      end
    end

    def app
      SimpleMetrics::App
    end

  end # describe "Sinatra App"

end
