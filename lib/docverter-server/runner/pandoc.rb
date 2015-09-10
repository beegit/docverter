class DocverterServer::Runner::Pandoc < DocverterServer::Runner::Base

  def run
    options = @manifest.command_options

    extension = DocverterServer::ConversionTypes.extension(@manifest['to'])
    output_file_name = generate_output_filename(extension)

    options = ['pandoc', '--standalone', "--output=#{output_file_name}"] + options
    run_command(options)
    output_file_name
  end

end
