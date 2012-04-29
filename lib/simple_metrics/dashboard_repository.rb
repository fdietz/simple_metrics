module SimpleMetrics
  class DashboardRepository

    class << self

      def find_one(id)
        dashboard(collection.find_one(BSON::ObjectId.from_string(id)))
      end

      def find_one_by_name(name)      
        result = collection.find({ :name => name }).to_a.first
        dashboard(result) if result
      end

      def find_all
        results = collection.find.sort([['name', ::Mongo::ASCENDING]]).to_a
        dashboards(results) if results
      end

      def save(dashboard)
        collection.insert(dashboard.attributes.merge(:created_at => Time.now.utc, :updated_at => Time.now.utc))
      end

      def update(dashboard)
        collection.update({ "_id" => dashboard.id }, { "$set" => { :updated_at => Time.now.utc }})  
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
        Repository.db.collection('dashboards')
      end

      def dashboard(result)
        Dashboard.new(:id => result["_id"], :name => result["name"], :created_at => result["created_at"], :updated_at => result["updated_at"])
      end

      def dashboards(results)
        results.inject([]) { |result, a| result << dashboard(a); }
      end

    end # class << self

  end
end