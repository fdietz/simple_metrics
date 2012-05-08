# encoding: utf-8
require "spec_helper"

module SimpleMetrics

  describe InstrumentRepository do

    before do
      InstrumentRepository.truncate_collections
    end

    let(:ts) do
      Time.now.utc.to_i
    end

    describe "#save" do
      it "saves instrument correctly" do
        instrument = Instrument.new(:name => "test")
        InstrumentRepository.save(instrument)

        results = InstrumentRepository.find_all
        results.should have(1).instrument
        results.first.name.should == "test"
      end
    end    

    describe "#find_all" do
      it "returns all instruments" do
        instrument1 = Instrument.new(:name => "test")
        instrument2 = Instrument.new(:name => "test2")
        InstrumentRepository.save(instrument1)
        InstrumentRepository.save(instrument2)

        results = InstrumentRepository.find_all
        results.should have(2).instruments
      end
    end   

    describe "#find_one_by_name" do
      it "returns all instruments" do
        instrument1 = Instrument.new(:name => "test")
        instrument2 = Instrument.new(:name => "test2")
        InstrumentRepository.save(instrument1)
        InstrumentRepository.save(instrument2)

        result = InstrumentRepository.find_one_by_name("test")
        result.name.should == "test"
      end
    end   
  end # describe InstrumentRepository

end