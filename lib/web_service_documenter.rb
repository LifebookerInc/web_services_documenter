$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'web_service_documenter'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'yaml'
require 'json'
require 'net/http'
require 'cgi'
require 'net/http/post/multipart'
require 'fileutils'
require 'erb'
require "active_support/all"
require "i18n"
require 'trollop'


module WebServiceDocumenter
  
  extend ActiveSupport::Autoload
  
  autoload :Helper
  autoload :Service
  autoload :ServiceCollection
  
  mattr_accessor :output_dir, :config, :base_uri, :web_services, :pages
  
  def self.generate(*path_to_web_services)
    opts = path_to_web_services.extract_options!
    
    self.output_dir = opts[:output] || File.expand_path("../../docs/", __FILE__)
    self.config     = YAML.load(ERB.new(File.read(path_to_web_services.first)).result).with_indifferent_access
    self.web_services = self.config["web_services"]
    self.base_uri     = self.config["settings"]["base_uri"]

    curl_services
  end

private

  def self.curl_services
    self.pages = []
    self.web_services.each do |web_service|
      if web_service["group"]
        service = ServiceCollection.new(web_service["group"])
        web_service["endpoints"].each do |ep|
          service << Service.new(self.base_uri, ep)
        end
      else
        service = Service.new(self.base_uri, web_service)
      end
      self.pages << {:path => service.generate_page, :title => service.title}
    end
    self.write_index
  end
  # writes the index file
  def self.write_index
    path = "#{WebServiceDocumenter.output_dir}/index.html"
    # create the path if necessary
    FileUtils.mkdir_p(File.dirname(path))
    # write out our file
    File.open(path, 'w+') do |f|
      erb = ::ERB.new(File.read(File.expand_path('../web_service_documenter/templates/index.html.erb', __FILE__)))
      f.write(erb.result(binding))
    end
  end
end
