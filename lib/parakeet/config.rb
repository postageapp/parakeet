require 'ostruct'

class Parakeet::Config
  # == Constants ============================================================

  PATH_DEFAULTS = %w[
    ~/.parakeet.yml
    ~/config/parakeet.yml
    ../../config/parakeet.yml
  ].freeze

  # == Properties ===========================================================

  attr_reader :instances
  
  # == Class Methods ========================================================

  def self.path_found
    PATH_DEFAULTS.map do |path|
      File.expand_path(path, File.dirname(__FILE__))
    end.find do |path|
      File.exist?(path)
    end
  end

  def self.convert(object)
    case (object)
    when Hash
      OpenStruct.new(
        object.map do |k,v|
          [ k,convert(v) ]
        end.to_h
      )
    when Array
      object.map do |v|
        convert(v)
      end
    else
      object
    end
  end

  def self.import(path, defaults = nil)
    if (path and File.exist?(path))
      self.convert(
        YAML.load(File.open(path)) || { }
      )
    else
      self.convert({ })
    end
  end

  # == Instance Methods =====================================================

  def initialize(path = nil)
    config = self.class.import(path || self.class.path_found)

    @instances = config.instances&.to_h || { }
  end
end
