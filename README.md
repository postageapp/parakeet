# Parakeet

A framework for creating Ruby background processes that can be started,
stopped, or run in interactive mode for debugging.

## Usage

To create a process it's necessary to define a `main` process that will run.
The most minimal form is this:

    require 'parakeet'

    Parakeet::Instance.new.main do
      loop do
        puts "Main process."

        sleep(1)
      end
    end.parse!(ARGV)

It's necessary to have some kind of event-loop running if this process is to
be persistent otherwise that block will terminate prematurely.

If this is saved in `example.rb` then this program can be launched:

    ruby example.rb run

In this mode the output from the program is directed to the console. To stop
the process use `^C`.

It can also be run as a background process if the location of any log files and
the PID file used to track status are defined:

    require 'parakeet'

    Parakeet::Instance.new.options do |program, options|
      options.pid_path = 'example.pid'
      options.log_path = 'example.log'
    end.main do
      loop do
        puts "Main process."

        sleep(1)
      end
    end.parse!(ARGV)

Then this can be launched as a background process:

    ruby example.rb start

Which, once running, will log to that directory instead of `STDOUT`. The
status of this process can be checked:

    ruby example.rb status

You can also stop this process any time:

    ruby example.rb stop

If the process finishes normally, that is does not return a non-zero exit code,
then it's presumed that the shutdown was deliberate and the process is allowed
to stop. If not, it's presumed there was an error or exception and after a
short delay it's restarted.
