# MongoidSphinx, a full text indexing extension for MongoDB/Mongoid using
# Sphinx.

module Mongoid
  module Sphinx
    extend ActiveSupport::Concern
    included do
      cattr_accessor :search_fields 
    end
    
    module ClassMethods
      def search_index(*fields)
        self.search_fields = fields
      end
      
      def search(query, options = {})
        client = MongoidSphinx::Configuration.instance.client
        query = query + " @classname #{self}"

        client.limit = options[:limit] if options.key?(:limit)
        client.match_mode = options[:match_mode] || :extended
        
        client.max_matches = options[:max_matches] if options.key?(:max_matches)
        client.rank_mode = options[:rank_mode] if options.key?(:rank_mode)
        client.sort_mode = options[:sort_mode] if options.key?(:sort_mode)
        
        if options.key?(:sort_by)
          client.sort_mode = :extended
          client.sort_by = options[:sort_by]
        end
        
        result = client.query(query)
        
        #TODO
        if result and result[:status] == 0 and (matches = result[:matches]) and result[:total_found]>0
          classname = nil
          ids = matches.collect do |row|
            classname = MongoidSphinx::MultiAttribute.decode(row[:attributes]['csphinx-class'])
            row[:doc].to_s rescue nil
          end.compact

          ids = ids.collect {|x| BSON::ObjectId.from_string((100000000000000000000000+x.to_i).to_s)} 
          return ids if options[:raw]
          return Object.const_get(classname).find(ids)
        else
          return []
        end
      end
    end
    
  end
end
