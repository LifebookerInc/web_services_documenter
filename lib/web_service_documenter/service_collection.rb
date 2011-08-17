module WebServiceDocumenter
  class ServiceCollection < Array
    attr_accessor :endpoint
    
    def initialize(endpoint)
      self.endpoint = endpoint
      super()
    end
    
    # title for the page
    def title
      self.endpoint
    end
    
    # generate a page - returns the path of the file generated
    def generate_page
      self.each(&:get_result)
      
      path = File.expand_path("#{WebServiceDocumenter.output_dir}/#{@endpoint.gsub(/\/$/,'').gsub(/\.\w*$/,'')}.html")
      # create the path if necessary
      FileUtils.mkdir_p(File.dirname(path))
      # write out our file
      File.open(path, 'w+') do |f|
        erb = ::ERB.new(File.read(File.expand_path('../templates/service.html.erb', __FILE__)))
        f.write(erb.result(binding))
      end
      path
    end
    
  end
end