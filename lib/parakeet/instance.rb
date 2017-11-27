class Parakeet::Instance
  # == Constants ============================================================
  
  # == Properties ===========================================================

  # == Class Methods ========================================================

  def self.options(&block)
    new(Parakeet::OptionParser.new(&block).options)
  end
  
  # == Instance Methods =====================================================

  def initialize(options = nil)
    @options = options || { }
  end

  def run(options = nil)
    yield(options || @options) if (block_given?)

  rescue Interrupt
    # Ignore, expected.
  end
end
