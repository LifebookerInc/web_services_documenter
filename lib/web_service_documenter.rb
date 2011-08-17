require 'yaml'
require 'json'
require 'net/http'
require 'cgi'
require 'net/http/post/multipart'
require 'fileutils'
require 'erb'
require File.expand_path('../web_service_documenter/helper',__FILE__)

require 'ruby-debug'
Debugger.start

class WebServiceDocumenter
  
  class << self
    def doc_dir
      @doc_dir
    end
    def doc_dir=(val)
      @doc_dir = val
    end
  end
  self.doc_dir = File.expand_path("../../docs/", __FILE__)
  
  class ServiceCollection < Array
    attr_accessor :endpoint
    
    def generate_page
      self.each(&:get_result)
      
      path = "#{WebServiceDocumenter.doc_dir}/#{@endpoint.gsub(/\/$/,'').gsub(/\.\w*$/,'')}.html"
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
  
  class Service
    
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

    def get_result
      
      endpoint = @endpoint.gsub(/\{(.*)\}/) do | i |
        @params[i.gsub(/(\{|\})/,'')]["example_value"]
      end
      
      url = "http://#{@base_uri}#{endpoint}"
      uri = URI.parse(url)

      puts "DOING #{url} with #{@example_params}"

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

      if !result.kind_of?(Net::HTTPOK)
        raise "Couldn't perform request with url: #{url}"
      end

      @response = JSON.parse(result.body)
    end
    
    # generate an individual page
    def generate_page
      self.get_result
      path = "#{WebServiceDocumenter.doc_dir}/#{@endpoint.gsub(/\/$/,'').gsub(/\.\w*$/,'')}.html"
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

      @params.each do |key, value|
        hash[key] = value["example_value"]
      end

      hash
    end
  end

  def self.generate(path_to_web_services)
    new.generate(path_to_web_services)
  end

  def generate(path_to_web_services)
    @yml_file     = YAML.load(ERB.new(File.read(path_to_web_services)).result)
    @web_services = @yml_file["web_services"]
    @base_uri     = @yml_file["settings"]["base_uri"]

    curl_services
  end

private

  def curl_services
    @pages = []
    @web_services.each do |web_service|
      if web_service["group"]
        service = ServiceCollection.new
        service.endpoint = web_service["group"]
        web_service["endpoints"].each do |ep|
          service << Service.new(@base_uri, ep)
        end
      else
        service = Service.new(@base_uri, web_service)
      end
      @pages << service.generate_page
    end
    puts @pages
  end
  
  def build_docs
    
  end
  
  
end
