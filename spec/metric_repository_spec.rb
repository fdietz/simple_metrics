# encoding: utf-8
require "spec_helper"

module SimpleMetrics

  describe MetricRepository do

    before do
      MetricRepository.truncate_collections
    end

    let(:ts) do
      Time.now.utc.to_i
    end

    describe "#save" do
      it "saves metric correctly" do
        metric = Metric.new(:name => "test", :total => 1)
        MetricRepository.save(metric)

        results = MetricRepository.find_all
        results.should have(1).metric
        results.first.name.should == "test"
        results.first.total.should == 1
      end
    end    

    describe "#find_all" do
      it "returns all metrics" do
        metric1 = Metric.new(:name => "test", :total => 1)
        metric2 = Metric.new(:name => "test2", :total => 1)
        MetricRepository.save(metric1)
        MetricRepository.save(metric2)

        results = MetricRepository.find_all
        results.should have(2).metrics
      end
    end   

    describe "#find_one_by_name" do
      it "returns all metrics" do
        metric1 = Metric.new(:name => "test", :total => 1)
        metric2 = Metric.new(:name => "test2", :total => 1)
        MetricRepository.save(metric1)
        MetricRepository.save(metric2)

        result = MetricRepository.find_one_by_name("test")
        result.name.should == "test"
      end
    end   
  end # describe MetricRepository

end