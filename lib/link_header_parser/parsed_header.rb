module LinkHeaderParser
  class ParsedHeader
    attr_reader :header

    def initialize(header, base:)
      raise ArgumentError, "header must be a String (given #{header.class})" unless header.is_a?(String)
      raise ArgumentError, "base must be a String (given #{base.class})" unless base.is_a?(String)

      @header = header
      @base = base
    end

    def inspect
      format(%(#<#{self.class.name}:%#0x @header="#{header.gsub('"', '\"')}">), object_id)
    end

    def parameters
      @parameters ||= OpenStruct.new(header_attributes)
    end

    def relation_types
      @relation_types ||= relations&.split(' ') || nil
    end

    def relations
      @relations ||= parameters.rel || nil
    end

    def target
      @target ||= header_match_data[:target]
    end

    def target_uri
      @target_uri ||= Absolutely.to_abs(base: @base, relative: target)
    end

    def to_h
      {
        target: target,
        target_uri: target_uri,
        relations: relations,
        relation_types: relation_types,
        parameters: parameters.to_h
      }
    end

    private

    def header_attributes
      @header_attributes ||= header_match_data[:attributes].tr('"', '').split(';').map { |tuple| tuple.split('=').map(&:strip) }.sort.to_h
    end

    def header_match_data
      @header_match_data ||= header.match(/^<\s*(?<target>[^>]+)\s*>\s*;\s*(?<attributes>.*)$/)
    end
  end
end
