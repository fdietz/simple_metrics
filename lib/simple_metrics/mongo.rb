# encoding: utf-8
require "mongo"

module SimpleMetrics
  module Mongo
    extend self

    def ensure_collections_exist
      SimpleMetrics.logger.debug "SERVER: MongoDB - found following collections: #{db.collection_names.inspect}"
      Bucket.all.each do |bucket|
        unless db.collection_names.include?(bucket.name)
          db.create_collection(bucket.name, :capped => bucket.capped, :size => bucket.size) 
          SimpleMetrics.logger.debug "SERVER: MongoDB - created collection #{bucket.name}, capped: #{bucket.capped}, size: #{bucket.size}"
        end
        db.collection(bucket.name).ensure_index([['ts', ::Mongo::ASCENDING]])
        SimpleMetrics.logger.debug "SERVER: MongoDB - ensure index on column ts for collection #{bucket.name}"
      end 
    end

    def truncate_collections
      Bucket.all.each do |bucket|
        if db.collection_names.include?(bucket.name)
          if bucket.capped?
            collection(bucket.name).drop # capped collections can't remove elements, drop it instead
          else
            collection(bucket.name).remove
          end
          SimpleMetrics.logger.debug "SERVER: MongoDB - truncated collection #{bucket.name}"
        end
      end
    end

    @@collection = {}
    def collection(name)
      @@collection[name] ||= db.collection(name)
    end

    def connection
      @@connection ||= ::Mongo::Connection.new(SimpleMetrics.db_config[:host], SimpleMetrics.db_config[:port], :slave_ok => true)
    end

    def db
      @@db ||= connection.db(SimpleMetrics.db_config[:db_name], SimpleMetrics.db_config[:options])
    end

  end
end
