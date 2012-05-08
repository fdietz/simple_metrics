module SimpleMetrics
  class InstrumentRepository

    class << self

      def find_one(id)
        instrument(collection.find_one(BSON::ObjectId.from_string(id)))
      end

      def find_one_by_name(name)      
        result = collection.find({ :name => name }).to_a.first
        instrument(result) if result
      end

      def find_all
        results = collection.find.sort([['name', ::Mongo::ASCENDING]]).to_a
        instruments(results) if results
      end

      def save(instrument)
        instrument.created_at = Time.now.utc
        instrument.updated_at = Time.now.utc
        attributes = instrument.attributes.reject { |key, value| key.to_s == "id" }
        id = collection.insert(attributes)
        instrument.id = id
        id
      end

      def update(instrument)
        collection.update({ "_id" => instrument.id }, "$set" => instrument.attributes.merge(:updated_at => Time.now.utc))
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
        Repository.db.collection('instruments')
      end

      def instrument(result)
        Instrument.new(:id => result["_id"], :name => result["name"], :metrics => result["metrics"], :created_at => result["created_at"], :updated_at => result["updated_at"])
      end

      def instruments(results)
        results.inject([]) { |result, a| result << instrument(a); }
      end

    end # class << self

  end
end