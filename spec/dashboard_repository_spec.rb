# encoding: utf-8
require "spec_helper"

module SimpleMetrics

  describe DashboardRepository do

    before do
      DashboardRepository.truncate_collections
    end

    let(:ts) do
      Time.now.utc.to_i
    end

    describe "#save" do
      it "saves dashboard correctly" do
        dashboard = Dashboard.new(:name => "test")
        DashboardRepository.save(dashboard)

        results = DashboardRepository.find_all
        results.should have(1).dashboard
        results.first.name.should == "test"
      end
    end    

    describe "#find_all" do
      it "returns all dashboards" do
        dashboard1 = Dashboard.new(:name => "test")
        dashboard2 = Dashboard.new(:name => "test2")
        DashboardRepository.save(dashboard1)
        DashboardRepository.save(dashboard2)

        results = DashboardRepository.find_all
        results.should have(2).dashboards
      end
    end   

    describe "#find_one_by_name" do
      it "returns all dashboards" do
        dashboard1 = Dashboard.new(:name => "test")
        dashboard2 = Dashboard.new(:name => "test2")
        DashboardRepository.save(dashboard1)
        DashboardRepository.save(dashboard2)

        result = DashboardRepository.find_one_by_name("test")
        result.name.should == "test"
      end
    end   
  end # describe DashboardRepository

end