require "mongo"

module SimpleMetrics
  class DataPointRepository

    class << self

      @@collection = {}

      def for_retention(name)
        self.new(collection(name))
      end

      def collection(name)
        raise ArgumentError, "Unknown retention: #{name}" unless retention_names.include?(name)
        @@collection[name] ||= db.collection(name)
      end

      def connection
        @@connection ||= ::Mongo::Connection.new(db_config[:host], db_config[:port])
      end

      def db
        @@db ||= connection.db(SimpleMetrics.db_name, SimpleMetrics.mongodb_options)
      end

      def db_config
        SimpleMetrics.db_config
      end

      def ensure_collections_exist
        SimpleMetrics.logger.debug "SERVER: MongoDB - found following collections: #{db.collection_names.inspect}"
        retentions.each do |retention|
          unless db.collection_names.include?(retention[:name])
            db.create_collection(retention[:name], :capped => retention[:capped], :size => retention[:size]) 
            SimpleMetrics.logger.debug "SERVER: MongoDB - created collection #{retention[:name]}, capped: #{retention[:capped]}, size: #{retention[:size]}"
          end
          
          db.collection(retention[:name]).ensure_index([['ts', ::Mongo::ASCENDING]])
          SimpleMetrics.logger.debug "SERVER: MongoDB - ensure index on column ts for collection #{retention[:name]}"
        end 
      end

      def truncate_collections
        retentions.each do |retention|
          if db.collection_names.include?(retention[:name])
            if retention[:capped]
              collection(retention[:name]).drop # capped collections can't remove elements, drop it instead
            else
              collection(retention[:name]).remove
            end
            SimpleMetrics.logger.debug "SERVER: MongoDB - truncated collection #{retention[:name]}"
          end
        end
      end

      private

      def retention_names
        retentions.map { |r| r[:name] }
      end

      def retentions
        @@buckets_config ||= SimpleMetrics.buckets_config
      end
    end

    def initialize(collection)
      @collection = collection
    end

    def save(result)
      @collection.insert(result.attributes)
    end

    def update(dp, ts)
      @collection.update({ "_id" => dp.id }, { "$set" => { :value => dp.value, :sum => dp.sum, :total => dp.total }})  
    end

    def find_all_at_ts(ts)
      results = @collection.find({ :ts => ts }).to_a
      data_points(results)
    end

    def find_data_point_at_ts(ts, name)
      result = @collection.find_one({ :ts => ts, :name => name })
      data_point(result) if result
    end

    def find_all_in_ts_range(from, to)
      results = @collection.find(range_query(from, to)).to_a
      data_points(results)
    end

    def find_all_in_ts_range_by_name(from, to, name)
      results = @collection.find({ :name => name }.merge(range_query(from, to))).to_a
      data_points(results)
    end

    def find_all_in_ts_range_by_wildcard(from, to, target)
      results = @collection.find({ :name => regexp(target) }.merge(range_query(from, to))).to_a
      data_points(results)
    end

    def count_at(ts)
      @collection.find({ :ts => ts }).count
    end

    def count_for_name_at(ts, name)
      @collection.find({ :ts => ts, :name => name }).count
    end

    def find_all_distinct_names
      @collection.distinct(:name).to_a
    end

    private

    def regexp(target)
      /#{wildcard_replace(target)}/
    end

    def wildcard_replace(target)
      target.gsub('.', '\.').gsub('*', '.*')
    end

    def range_query(from, to)
      { :ts => { "$gte" => from, "$lte" => to } }
    end

    def data_point(result)
      DataPoint.build(:id => result["_id"], :name => result["name"], :value => result["value"], :ts => result["ts"], :type => result["type"], :sum => result["sum"], :total => result["total"])
    end

    def data_points(results)
      results.inject([]) { |result, a| result << data_point(a); }
    end
  end
end