require_relative 'field_type'
require_relative 'filter'
require_relative 'tokenizer'

class Analyzer
    attr_accessor :name

    def initialize(name)
        @name = name
    end

    def tokenizer
        Tokenizer.new
    end

    def filters
        Array(Filter.get_filter(name).new)
    end

    def to_json
        {
            "tokenizer": tokenizer.to_json,
            "filters": filters.map { |filt| filt.to_json }
        }
    end
end

class ISBNAnalyzer < Analyzer
    def tokenizer
        PatternTokenizer.new("[;,]\s*")
    end

    def filters
        [
            Filter.new("edu.umich.lib.solr_filters.ISBNNormalizerFilterFactory"),
            Filter.new("solr.RemoveDuplicatesTokenFilterFactory"),
            Filter.get_filter('length').new(max=13, min=13)
        ]
    end

    def to_json
        {
            "tokenizer": tokenizer.to_json,
            "filters": filters.map { |filt| filt.to_json }
        }
    end
end

class ParseCallNumberAnalyzer
    def tokenizer
        Tokenizer.new
    end

    def filters
        [].append(ParseCallNumberFilter.new.sub_filters).flatten
    end

    def to_json
        {
            "tokenizer": tokenizer.to_json,
            "filters": filters.map { |filt| filt.to_json }
        }
    end
end


class ISBNFieldType
    FieldType.register(self)

    def self.handles?(name)
        name == 'isbn'
    end

    def name
        'isbn'
    end

    def solr_class
        'solr.TextField'
    end

    def analyzer
        ISBNAnalyzer.new(name)
    end

    def to_json
        {
            "name": name,
            "class": solr_class,
            "analyzer": analyzer.to_json
        }
    end
end

class LCCNFieldType
    FieldType.register(self)

    def self.handles?(name)
        name == 'lccn'
    end

    def name
        'lccn'
    end

    def solr_class
        'solr.TextField'
    end

    def analyzer
        Analyzer.new(name)
    end

    def to_json
        {
            "name": name,
            "class": solr_class,
            "analyzer": analyzer.to_json
        }
    end
end

class LCCNSortableFieldType
    FieldType.register(self)

    def self.handles?(name)
        name == "lc_callnumber_sortable"
    end

    def name
        "lc_callnumber_sortable"
    end

    def solr_class
        "solr.TextField"
    end

    def analyzer
        ParseCallNumberAnalyzer.new
    end

    def to_json
        {
            "name": name,
            "class": solr_class,
            "analyzer": analyzer.to_json
        }
    end
end