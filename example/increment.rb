# encoding: utf-8
require "rubygems"
require "bundler/setup"
require "simple_metrics"

client = SimpleMetrics::Client.new("localhost")
# com.example.test1:1|c
client.increment("com.example.test1")
