require 'ostruct'

class Parakeet::Config < OpenStruct
  # == Constants ============================================================

  PATH_DEFAULTS = %w[
    ../../config/parakeet.yml
    ~/config/parakeet.yml
    ~/.parakeet.yml
  ].freeze
  
  # == Class Methods ========================================================

  def self.path_found
    PATH_DEFAULTS.map do |path|
      File.expand_path(path, File.dirname(__FILE__))
    end.find do |path|
      File.exist?(path)
    end
  end
  
  # == Instance Methods =====================================================

  def initialize(path = nil)
    path || self.class.path_found

    super(YAML.load(File.open(path)))
  end
end
