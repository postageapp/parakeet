require 'optparse'
require 'ostruct'
require 'yaml'

class Parakeet::OptionParser
  # == Constants ============================================================
  
  # == Properties ===========================================================

  attr_reader :args
  attr_reader :options

  # == Class Methods ========================================================
  
  # == Instance Methods =====================================================

  def initialize(options = nil)
    @options = OpenStruct.new(options || { })

    program = ::OptionParser.new do |opts|
      opts.on('-f', '--config PATH', 'Path to configuration file') do |path|
        @options.config = path
      end
    end

    yield(program, @options) if (block_given?)

    @args = program.parse(ARGV)

    if (@options[:config])
      @options = OpenStruct.new(
        YAML.load(File.open(@options[:config])).merge(@options.to_h)
      )
    end
  end
end
