module WebServiceDocumenter
  class Service
    
    include Path
    
    attr_accessor :base_uri, :endpoint, :params, :description, :multipart, :method, :example_params, :response
    
    def initialize(base_uri, options)
      @base_uri       = base_uri
      @endpoint       = options["endpoint"]
      @params         = options["params"]
      @description    = options["description"]
      @multipart      = options["multipart"] || false
      @method         = (options["method"] || "get").downcase
      @example_params = create_example_params
    end

    # endpoint is the title for now
    def title
      self.endpoint
    end

    def transform_multipart_example_params
      new_params = {}

      @example_params.map do |key, value|
        if value =~ /file\((.*)\,(.*)\,(.*)\)/
          new_params[key] = UploadIO.new($1.strip, $2.strip, $3.strip)
        else
          new_params[key] = value
        end
      end

      new_params
    end

    # get the result of the web request
    def get_result
      uri = URI.parse(self.url)
      
      # debugging output
      WebServiceDocumenter.log("Getting #{self.url}")
      
      result = if @method =~ /post/
        if @multipart == true
          request = Net::HTTP::Post::Multipart.new uri.path, transform_multipart_example_params

          Net::HTTP.start(uri.host, uri.port) do |http|
            http.request(request)
          end
        else
          Net::HTTP.post_form(uri, @example_params)
        end
      else
        http = Net::HTTP.new(uri.host, uri.port)
        request = Net::HTTP::Get.new(uri.path)
        request.set_form_data(@example_params)

        request  = Net::HTTP::Get.new("#{uri.path}?#{request.body}")
        http.request(request)
      end

      unless result.code.to_s =~ /^2\d{2}$/
        require 'pp'
        puts JSON.parse(result.body).pretty_inspect
        raise "Couldn't perform request with url: #{url}"
      end

      @response = JSON.parse(result.body)
      @response = @response.first if @response.is_a?(Array)
      @response
    end
    
    def url
      endpoint = @endpoint.gsub(/\{([^\}]+)\}/) do | i |
        @params[i.gsub(/(\{|\})/,'')]["example_value"]
      end
      url = "http://#{@base_uri}#{endpoint}"
    end
    
    # generate an individual page
    def generate_page
      self.get_result
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

  private

    def create_example_params
      hash = {}
      (@params || {}).each do |key, value|
        hash[key] = value["example_value"]
      end
      hash
    end
  end
end
