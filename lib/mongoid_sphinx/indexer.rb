# MongoidSphinx, a full text indexing extension for MongoDB using
# Sphinx.
#
# This file contains the MongoidSphinx::Indexer::XMLDocset and
# MongoidSphinx::Indexer::XMLDoc classes.

module MongoidSphinx #:nodoc:

  # Module Indexer contains classes for creating XML input documents for the
  # indexer. Each Sphinx index consists of a single "sphinx:docset" with any
  # number of "sphinx:document" tags.
  #
  # The XML source can be generated from an array of CouchRest objects or from
  # an array of Hashes containing at least fields "classname" and "_id"
  # as returned by MongoDB view "MongoSphinxIndex/couchrests_by_timestamp".
  #
  # Sample:
  #
  #   rows = [{ 'name' => 'John', 'phone' => '199 43828',
  #             'classname' => 'Address', '_id' => 'Address-234164'
  #           },
  #           { 'name' => 'Sue', 'mobile' => '828 19439',
  #             'classname' => 'Address', '_id' => 'Address-422433'
  #          }
  #   ]
  #   puts MongoSphinx::Indexer::XMLDocset.new(rows).to_s
  #
  #   <?xml version="1.0" encoding="utf-8"?>
  #   <sphinx:docset>
  #     <sphinx:schema>
  #       <sphinx:attr name="csphinx-class" type="multi"/>
  #       <sphinx:field name="classname"/>
  #       <sphinx:field name="name"/>
  #       <sphinx:field name="phone"/>
  #       <sphinx:field name="mobile"/>
  #       <sphinx:field name="created_at"/>
  #     </sphinx:schema>
  #     <sphinx:document id="234164">
  #       <csphinx-class>336,623,883,1140</csphinx-class>
  #       <classname>Address</classname>
  #       <name><![CDATA[[John]]></name>
  #       <phone><![CDATA[[199 422433]]></phone>
  #       <mobile><![CDATA[[]]></mobile>
  #       <created_at><![CDATA[[]]></created_at>
  #     </sphinx:document>
  #     <sphinx:document id="423423">
  #       <csphinx-class>336,623,883,1140</csphinx-class>
  #       <classname>Address</classname>
  #       <name><![CDATA[[Sue]]></name>
  #       <phone><![CDATA[[]]></phone>
  #       <mobile><![CDATA[[828 19439]]></mobile>
  #       <created_at><![CDATA[[]]></created_at>
  #     </sphinx:document>
  #   </sphinx:docset>"

  module Indexer

    # Class XMLDocset wraps the XML representation of a document to index. It
    # contains a complete "sphinx:docset" including its schema definition.
    
    class XMLDocset

      # Streams xml of all objects in a klass to the stdout. This makes sure you can process large collections.
      #
      # Options:
      #  attributes (required) - The attributes that are put in the sphinx xml.
      #
      # Example:
      #  MongoSphinx::Indexer::XMLDocset.stream(Document, :attributes => %w(title content))
      # This will create an XML stream to stdout. 
      #
      # Configure in your sphinx.conf like
      #  xmlpipe_command = ./script/runner "MongoSphinx::Indexer::XMLDocset.stream(Document, :attributes => %w(title content))"
      #
      def self.stream(klass)
        STDOUT.sync = true # Make sure we really stream..

        puts '<?xml version="1.0" encoding="utf-8"?>'
        puts '<sphinx:docset>'

        # Schema
        puts '<sphinx:schema>'
        klass.search_fields.each do |key, value|
          puts "<sphinx:field name=\"#{key}\"/>"
        end
        # FIXME: What is this attribute?
        puts '<sphinx:field name="classname"/>'
        puts '<sphinx:attr name="csphinx-class" type="multi"/>'
        puts '</sphinx:schema>'
        
        collection = Mongoid.database.collection(klass.collection.name)
        collection.find.each do |document_hash|
          XMLDoc.stream_for_hash(document_hash, klass)
        end

        puts '</sphinx:docset>'
      end
      
    end

    class XMLDoc

      def self.stream_for_hash(hash, klass)
        sphinx_compatible_id = hash['_id'].to_s.to_i - 100000000000000000000000
        
        puts "<sphinx:document id=\"#{sphinx_compatible_id}\">"
        # FIXME: Should we include this?
        puts '<csphinx-class>'
        puts MongoidSphinx::MultiAttribute.encode(klass.to_s)
        puts '</csphinx-class>'
        puts "<classname>#{klass.to_s}</classname>"
        
        klass.search_fields.each do |key|
          value = hash[key.to_s]
         # puts "<#{key}><![CDATA[[#{EscapeUtils.escape_html(value.to_s)}]]></#{key}>"
         puts "<#{key}><![CDATA[[#{value.to_s}]]></#{key}>"
        end

        puts '</sphinx:document>'
      end
      
    end
  end
end
