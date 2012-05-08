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

      def ensure_collections_exist
        SimpleMetrics.logger.debug "SERVER: MongoDB - found following collections: #{db.collection_names.inspect}"
        buckets.each do |retention|
          unless db.collection_names.include?(retention.fetch(:name))
            db.create_collection(retention.fetch(:name), :capped => retention.fetch(:capped), :size => retention.fetch(:size)) 
            SimpleMetrics.logger.debug "SERVER: MongoDB - created collection #{retention.fetch(:name)}, capped: #{retention.fetch(:capped)}, size: #{retention.fetch(:size)}"
          end
          
          db.collection(retention.fetch(:name)).ensure_index([['ts', ::Mongo::ASCENDING]])
          db.collection(retention.fetch(:name)).ensure_index([['_id', ::Mongo::ASCENDING]])
          SimpleMetrics.logger.debug "SERVER: MongoDB - ensure index on column ts for collection #{retention.fetch(:name)}"
        end 
      end

      def truncate_collections
        buckets.each do |retention|
          if db.collection_names.include?(retention.fetch(:name))
            if retention.fetch(:capped)
              collection(retention.fetch(:name)).drop # capped collections can't remove elements, drop it instead
            else
              collection(retention.fetch(:name)).remove
            end
            SimpleMetrics.logger.debug "SERVER: MongoDB - truncated collection #{retention.fetch(:name)}"
          end
        end
      end

      private

      def db
        Repository.db
      end

      def retention_names
        buckets.map { |r| r.fetch(:name) }
      end

      def buckets
        SimpleMetrics.config.buckets
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

    def find_all_in_ts_range_by_name(from, to, name)
      results = @collection.find({ :name => name }.merge(range_query(from, to))).to_a
      data_points(results)
    end

    def find_all_in_ts_range_by_wildcard(from, to, target)
      results = @collection.find({ :name => regexp(target) }.merge(range_query(from, to))).to_a
      data_points(results)
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