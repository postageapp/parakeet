require 'birling'

class Parakeet::Instance
  # == Constants ============================================================

  # == Properties ===========================================================

  # == Class Methods ========================================================

  # == Instance Methods =====================================================

  def initialize
    yield(self) if (block_given?)

    @daemonized = false
  end

  def program_name
    File.basename($0)
  end

  def parser(&block)
    @parser ||= Parakeet::OptionParser.new(program_name: self.program_name, &block)
  end

  def options(&block)
    self.parser(&block)

    self
  end

  def then(&block)
    (@then ||= [ ]) << block

    self
  end

  def main(&block)
    @exec = block

    self
  end

  def call
    @exec.call(@parser.options, @daemonized)

  rescue Interrupt
    # Ignore, expected.
  end

  def logger
    @logger ||= Birling.open(@parser.options.log_path)
  end

  def parse!(argv)
    self.parser.parse(argv)

    @then and @then.each do |proc|
      proc.call(@parser.options)
    end

    case (parser.args.first)
    when 'run'
      self.call
    when 'start'
      @daemonized = true

      daemonized do |daemon|
        if (pid = daemon.running_pid)
          yield(:start, pid, pid) if (block_given?)
        else
          daemon.start!(self.logger) do |pid|
            yield(:start, pid) if (block_given?)
          end
        end
      end
    when 'stop'
      daemonized do |daemon|
        daemon.stop! do |pid|
          yield(:stop, pid) if (block_given?)
        end
      end
    when 'restart'
      daemonized do |daemon|
        daemon.restart! do |pid, old_pid|
          yield(:restart, pid, old_pid) if (block_given?)
        end
      end
    when 'status'
      daemonized do |daemon|
        daemon.status do |pid|
          yield(:status, pid) if (block_given?)
        end
      end
    else
      puts self.parser.to_s
    end

    self
  end

protected
  def daemonized(&block)
    Parakeet::Daemonizer.new(
      self,
      pid_path: @parser.options.pid_path,
      &block
    )
  end

  def redirect_stdout!
    $stdout = self.logger
  end

  def redirect_stderr!
    $stderr = self.logger
  end
end
