class Parakeet::Daemonizer
  # == Constants ============================================================
  
  # == Properties ===========================================================
  
  # == Extensions ===========================================================
  
  # == Relationships ========================================================
  
  # == Validations ==========================================================
  
  # == Callbacks ============================================================
  
  # == Scopes ===============================================================
  
  # == Class Methods ========================================================
  
  # == Instance Methods =====================================================

  def initialize(instance, pid_path:)
    @instance = instance
    @pid_path = pid_path

    yield(self) if (block_given?)
  end

  def pid_exists?
    File.exist?(@pid_path)
  end

  def pid
    self.pid_exists? and File.read(@pid_path).chomp.to_i
  end

  def pid=(pid)
    File.open(@pid_path, 'w') do |f|
      f.write(pid)
    end
  end

  def running?
    !!self.running_pid
  end

  def running_pid
    _pid = self.pid

    (_pid and Process.kill(0, _pid)) ? _pid : nil

  rescue Errno::ESRCH => e
    nil
  end

  def start!(logger = nil)
    pid =
      if (running?)
        self.running_pid
      else
        daemonize(logger) do
          @instance.call
        end
      end

    self.pid = pid

    yield(pid) if (block_given?)

    pid
  end

  def stop!
    pid = self.pid
    
    if (pid)
      begin
        Process.kill('INT', pid)
        
      rescue Errno::ESRCH
        # No such process exception
      end
      
      begin
        while (pid and Process.kill(0, pid))
          self.nap(0.1)
        end

      rescue Errno::ESRCH
        # No such process, already terminated
      end

      File.unlink(@pid_path)
    end

    yield(pid) if (block_given?)
    
    pid
  end

  def restart!
    self.stop! do |old_pid|
      self.start! do |pid|
        yield(pid, old_pid) if (block_given?)
      end
    end
  end

  def status
    yield(self.running_pid) if (block_given?)
  end

protected
  def daemonize(logger = nil)
    # Set up a pipe so that the intermediate process can send back a PID
    rfd, wfd = IO.pipe
    delay = 10
    
    forked_pid = fork do
      rfd.close

      supervisor_pid = fork do
        relaunch = true

        if (logger)
          $stdout = logger
          $stderr = logger
        end
        
        while (relaunch)
          daemon_pid = fork do
            begin
              yield
            rescue SystemExit
              # Forced exit from supervisor process
            rescue Object => e
              if (logger)
                logger.error("Terminated with Exception: [#{e.class}] #{e}")
                logger.error(e.backtrace.join("\n"))

                Thread.list.each do |thread|
                  logger.error("Stack trace of current threads")
                  logger.error(thread.inspect)
                  
                  if (thread.backtrace)
                    logger.error("\t" + thread.backtrace.join("\n\t"))
                  end
                end
              end

              exit(-1)
            end
          end

          begin
            interrupted = false

            Signal.trap('INT') do
              interrupted = true
              Process.kill('INT', daemon_pid)

              relaunch = false
            end

            _, status = Process.wait2(daemon_pid)

            if (interrupted)
              logger and logger.info("Supervisor #{Process.pid} received termination signal, shut down child #{daemon_pid}.")
            end

            # A non-zero exit status indicates some sort of error, so the
            # process will be relaunched after a short delay.
            relaunch = (status != 0)

          ensure
            # Reset Signal handler before forking again
            Signal.trap('INT') do
            end
          end
          
          if (relaunch)
            begin
              logger and logger.info("Supervisor #{Process.pid} will relaunch in %d seconds" % delay)
              sleep(delay)

            rescue Interrupt
              logger and logger.info("Supervisor #{Process.pid} abandoing restart because of termination")

              relaunch = false
            end
          else
            logger and logger.info("Terminated normally.")
          end
        end
      end

      wfd.puts(supervisor_pid)
      wfd.flush
      wfd.close
    end

    # Wait for the intermediate process to finish
    Process.wait2(forked_pid)

    # Pullout the PID data
    rfd.readline.to_i

  ensure
    rfd.close
  end

  def nap(time)
    select(nil, nil, nil, time.to_f)
  end
end
