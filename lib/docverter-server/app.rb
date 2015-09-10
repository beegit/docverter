require 'sinatra/base'
require 'fileutils'

class DocverterServer::App < Sinatra::Base

  set :show_exceptions, false
  set :dump_errors, false
  set :raise_errors, true
  
  MAX_RETRIES = 10

  post '/convert' do
    @output = nil

    num_tries = 0
    input_files = params.delete('input_files') || []
    other_files = params.delete('other_files') || []
    tmp_dir = Dir.mktmpdir
    manifest = DocverterServer::Manifest.new

    input_files.each do |upload|
      input_filepath = File.join(tmp_dir, upload[:filename])
      FileUtils.cp upload[:tempfile].path, input_filepath
      manifest['input_files'] << input_filepath
    end

    other_files.each do |upload|
      FileUtils.cp upload[:tempfile].path, File.join(tmp_dir, upload[:filename])
    end

    params.each do |key,val|
      next if key == 'controller' || key == 'action'
      key = key.gsub("'", '') if key.is_a?(String)
      val = val.gsub("'", '') if val.is_a?(String)

      manifest[key] = val
    end

    output_file_name = DocverterServer::Conversion.new(tmp_dir, nil, {}, manifest).run
    content_type(DocverterServer::ConversionTypes.mime_type(manifest['to']))

    while num_tries < MAX_RETRIES
      num_tries += 1
      puts "Attempt ##{num_tries}: Attempting to open converted file '#{File.join(tmp_dir, output_file_name)}'"
      begin
        File.open(output_file_name) do |f|
          @output = f.read
        end
        break
      rescue => ex
        if num_tries >= MAX_RETRIES
          raise ex
        end

        @output = ''
        sleep 0.025
      end
    end

    manifest.cleanup
    File.delete(output_file_name)

    @output
  end

  get '/' do
    'hi'
  end
end
