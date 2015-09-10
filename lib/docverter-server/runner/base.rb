require 'open3'
require 'securerandom'
require 'shellwords'

module DocverterServer
  module Runner
    class Base
      include Logging
      
      attr_reader :directory, :input_filename, :options

      def initialize(directory, input_filename = nil, options= {}, manifest=nil)
        @directory = directory
        @input_filename = input_filename
        @options = {}
        @manifest = manifest
      end

      def run
        raise "implement in subclass"
      end

      def generate_output_filename(extension)
        File.join(@directory, "output.#{SecureRandom.hex(10)}.#{extension}")
      end

      def run_command(options)
        output = ""
        cmd = Shellwords.join(options) + " 2>&1"

        IO.popen(cmd) do |io|
          output = io.read
        end
        
        if $?.exitstatus != 0
          raise DocverterServer::CommandError.new(output)
        else
          logger.info "Command Complete: Result: #{$?} - Options: #{options}"
        end
      end
    end
  end
end
