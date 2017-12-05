require 'rubygems'
require 'bundler'

begin
  Bundler.setup(:default, :development, :test)

rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'test/unit'
require 'test_plus'

$LOAD_PATH << File.expand_path('../lib', File.dirname(__FILE__))

require 'parakeet'

class Test::Unit::TestCase
  include TestPlus::Extensions

  def example_path(name)
    File.expand_path(
      name,
      File.expand_path('./examples/', File.dirname(__FILE__))
    )
  end
end
