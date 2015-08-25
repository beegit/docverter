class DocverterServer::Conversion < DocverterServer::Runner::Base

  def run
    @manifest.validate!(directory)

    if @manifest['to'] == 'pdf'
      @manifest['to'] = 'html'

      if @manifest['from'] != 'html'
        @html_filename = DocverterServer::Runner::Pandoc.new(directory, nil, {}, @manifest).run
      else
        @html_filename = @manifest['input_files'][0]
      end
      @output_filename = DocverterServer::Runner::PDF.new(directory, @html_filename, {}, @manifest).run
    elsif @manifest['to'] == 'mobi'
      @manifest['to'] = 'epub'

      epub = DocverterServer::Runner::Pandoc.new('.', nil, {}, @manifest).run
      @output_filename = DocverterServer::Runner::Calibre.new(directory, epub, {}, @manifest).run
    else
      @output_filename = DocverterServer::Runner::Pandoc.new(directory, nil, {}, @manifest).run
    end
    @output_filename
  end

  def output_mime_type
    DocverterServer::ConversionTypes.mime_type(@manifest.pdf ? 'pdf' : @manifest['to'])
  end

  def output_extension
    DocverterServer::ConversionTypes.extension(@manifest.pdf ? 'pdf' : @manifest['to'])
  end

end
