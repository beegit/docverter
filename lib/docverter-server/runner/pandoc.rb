class DocverterServer::Runner::Pandoc < DocverterServer::Runner::Base

  def run
    options = @manifest.command_options

    extension = DocverterServer::ConversionTypes.extension(@manifest['to'])
    output = generate_output_filename(extension)

    options = ['pandoc', '--standalone', "--output=#{output}"] + options
    run_command(options)
    output
  end

end
