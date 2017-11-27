require 'rubygems'
require 'bundler'

begin
  Bundler.setup(:default, :development)

rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'test/unit'

$LOAD_PATH << File.expand_path('../lib', File.dirname(__FILE__))

require 'parakeet'

class Test::Unit::TestCase
end
