# Parakeet

A framework for launching, supervising and updating persistent processes.
Initially targeting Ruby, can theoretically also accommodate JRuby and Node.js
applications.

## Usage

To display all processes on the system that are currently configured to run:

    parakeet list

To stop all processes:

    parakeet kill --all

To start all processes:

    parakeet start --all

Where a process has an update procedure:

    parakeet upgrade --all

## Configuration

Parakeet can take configuration details from a local config file, but this can
also reference network resources to supply more information. For example,
Redis can also be referenced to pull down additional configuration details.

## Building a Parakeet Compatible Application

Included with the library is a launcher utility that can be used to build
small, simple background processes.

A very minimal worker process looks like:

    require 'parakeet'

    Parakeet.run do
      # Application code goes here.
    end

It's necessary to have some kind of event-loop running if this process is to
be persistent otherwise that block will terminate prematurely and the process
will restart automatically on the presumption that something crashed.

### Logging

Logging can be done to a file, or advertised over an AMQP system like RabbitMQ.
