module LinkHeaderParser
  class ParsedHeader
    attr_reader :header, :parameters, :target

    def initialize(header, base:)
      raise ArgumentError, "header must be a String (given #{header.class})" unless header.is_a?(String)
      raise ArgumentError, "base must be a String (given #{base.class})" unless base.is_a?(String)

      @header = header
      @base = base

      match_data = header.match(/^<\s*(?<target>[^>]+)\s*>\s*;\s*(?<attributes>.*)$/)

      @target = match_data[:target]
      @parameters = self.class.parameters_from(match_data[:attributes])
    end

    def inspect
      format(%(#<#{self.class.name}:%#0x @header="#{header.gsub('"', '\"')}">), object_id)
    end

    def relation_types
      @relation_types ||= relations&.split(' ') || nil
    end

    def relations
      @relations ||= parameters.rel || nil
    end

    def target_uri
      @target_uri ||= Absolutely.to_abs(base: @base, relative: @target)
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

    def self.parameters_from(attributes)
      OpenStruct.new(attributes.tr('"', '').split(';').map { |tuple| tuple.split('=').map(&:strip) }.sort.to_h)
    end
  end
end