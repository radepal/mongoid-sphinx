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
                 
        query = query + " @classname #{@document.class.to_s}"
        
        client.match_mode = options[:match_mode] || :extended
        client.limit = options[:limit] if options.key?(:limit)
        client.max_matches = options[:max_matches] if options.key?(:max_matches)
        
        if options.key?(:sort_by)
          client.sort_mode = :extended
          client.sort_by = options[:sort_by]
        end
        
        result = client.query(query)
        
        #TODO
        if result and result[:status] == 0 and (matches = result[:matches])
          classname = nil
          ids = matches.collect do |row|
            classname = MongoidSphinx::MultiAttribute.decode(row[:attributes]['csphinx-class'])
            row[:doc].to_s rescue nil
          end.compact
          
          return ids if options[:raw]
          return Object.const_get(classname).find(ids)
        else
          return []
        end
      end
    end
    
  end
end
