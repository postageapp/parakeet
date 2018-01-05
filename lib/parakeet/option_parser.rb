require 'optparse'
require 'ostruct'
require 'yaml'

class Parakeet::OptionParser
  # == Constants ============================================================
  
  # == Properties ===========================================================

  attr_reader :args
  attr_reader :options
  attr_reader :program_name

  # == Class Methods ========================================================
  
  # == Instance Methods =====================================================

  def initialize(program_name: nil)
    @program_name = program_name
    @options = OpenStruct.new

    @program = ::OptionParser.new do |opts|
      opts.banner = 'Usage: %s [options] run|start|stop|restart|status' % [
        @program_name
      ]
      opts.on('-f', '--config PATH', 'Path to configuration file') do |path|
        @options.config = path
      end
      opts.on('-p', '--pid-file PATH', 'Path to PID file') do |path|
        @options.pid_path = path
      end
    end

    yield(@program, @options) if (block_given?)
  end

  def parse(args)
    @args = @program.parse(args)

    if (@options[:config])
      @options = OpenStruct.new(
        YAML.load(File.open(@options[:config])).merge(@options.to_h)
      )
    end
  end

  def to_s
    @program.to_s
  end
end
