require 'ostruct'

class Parakeet::Config
  # == Constants ============================================================

  PATH_DEFAULTS = %w[
    ../../config/parakeet.yml
    ~/config/parakeet.yml
    ~/.parakeet.yml
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

  # == Instance Methods =====================================================

  def initialize(path = nil)
    @instances = YAML.load(File.open(path || path_found)).map do |instance, instance_config|
      [ instance, self.class.convert(instance_config) ]
    end.to_h
  end
end
