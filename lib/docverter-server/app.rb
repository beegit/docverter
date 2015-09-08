require 'sinatra/base'
require 'fileutils'

class DocverterServer::App < Sinatra::Base

  set :show_exceptions, false
  set :dump_errors, false
  set :raise_errors, true
  MAX_RETRIES = 10

  post '/convert' do

    Dir.chdir(settings.tmpdir) do
      num_tries = 0
      manifest = DocverterServer::Manifest.new

      input_files = params.delete('input_files') || []
      other_files = params.delete('other_files') || []

      input_files.each do |upload|
        FileUtils.cp upload[:tempfile].path, upload[:filename]
        manifest['input_files'] << upload[:filename]
      end

      other_files.each do |upload|
        FileUtils.cp upload[:tempfile].path, upload[:filename]
      end

      params.each do |key,val|
        next if key == 'controller' || key == 'action'
        key = key.gsub("'", '') if key.is_a?(String)
        val = val.gsub("'", '') if val.is_a?(String)

        manifest[key] = val
      end

      output_file = DocverterServer::Conversion.new(settings.tmpdir, nil, {}, manifest).run
      content_type(DocverterServer::ConversionTypes.mime_type(manifest['to']))

      @output = nil

      while num_tries < MAX_RETRIES
        num_tries += 1
        begin
          File.open(output_file) do |f|
            @output = f.read
          end
          break
        rescue => ex
          puts "Failed to open #{output_file}; num_tries = #{num_tries}"

          if num_tries >= MAX_RETRIES
            raise ex
          end

          @output = ''
          sleep 0.020
        end
      end

      manifest.cleanup
      File.delete(output_file)

      @output
    end

  end

  get '/' do
    'hi'
  end
end

DocverterServer::App.set :tmpdir, Dir.mktmpdir
