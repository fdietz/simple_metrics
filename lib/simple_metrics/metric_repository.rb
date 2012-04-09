module SimpleMetrics
  class MetricRepository

    class << self

      def find_one(id)
        metric(collection.find_one(id))
      end

      def find_one_by_name(name)      
        result = collection.find({ :name => name }).to_a.first
        metric(result) if result
      end

      def find_all
        results = collection.find.to_a
        metrics(results) if results
      end

      def save(metric)
        collection.insert(metric.attributes.merge(:created_at => Time.now.utc, :updated_at => Time.now.utc))
      end

      def update(metric)
        collection.update({ "_id" => metric.id }, { "$set" => { :total => metric.total, :updated_at => Time.now.utc }})  
      end

      def truncate_collections
        collection.remove
      end

      def ensure_index
        collection.ensure_index([['created_at', ::Mongo::ASCENDING]])
        collection.ensure_index([['updated_at', ::Mongo::ASCENDING]])
        collection.ensure_index([['name', ::Mongo::ASCENDING]])
      end

      private

      def collection
        Repository.db.collection('metrics')
      end

      def metric(result)
        Metric.new(:id => result["_id"], :name => result["name"], :total => result["total"], :created_at => result["created_at"], :updated_at => result["updated_at"])
      end

      def metrics(results)
        results.inject([]) { |result, a| result << metric(a); }
      end
    end

  end
end