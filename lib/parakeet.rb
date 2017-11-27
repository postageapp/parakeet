module Parakeet
  # == Constants ============================================================
  
  # == Module Methods =======================================================

  def self.config(path = nil)
    Parakeet::Config.import(path)
  end
end

require_relative './parakeet/config'
require_relative './parakeet/instance'
require_relative './parakeet/manager'
require_relative './parakeet/option_parser'
