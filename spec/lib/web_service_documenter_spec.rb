require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "WebServiceDocumenter" do
  
  before :each do
    
    # set up the mocks
    success_mock = mock('Net::HTTPOK')
    success_mock.stubs(:code => "200", :message => "OK", :body => {"user" => {"first_name" => "Dan", "last_name" => "Langevin"}}.to_json)
    Net::HTTP.any_instance.stubs(:request).returns(success_mock)
    
    # write out our config
    @config_file = File.expand_path("../../config/endpoints.yml", __FILE__)
    
    @output_dir = File.expand_path("../../tmp", __FILE__)
    FileUtils.rm_rf(@output_dir)
    
    
  end
  context "Configuration" do
    it "takes options for output directory" do
      WebServiceDocumenter.generate(@config_file, :output => @output_dir)
      Dir["#{@output_dir}/users*"].length.should eql 1
    end
    it "loads a configuration file" do
      WebServiceDocumenter.generate(@config_file, :output => @output_dir)
      WebServiceDocumenter.base_uri.should eql("localhost.com")
      WebServiceDocumenter.config["web_services"].should be_instance_of Array
      WebServiceDocumenter.config["web_services"].should_not be_blank
    end
  end
  
  it "accepts a collection of services for a given endpoint and render them on one page" do
    @config_file = File.expand_path("../../config/group_endpoints.yml", __FILE__)
    WebServiceDocumenter.generate(@config_file, :output => @output_dir)
    Dir["#{@output_dir}/users*"].length.should eql 1
    f = File.read("#{@output_dir}/users.html")
    f.should =~ Regexp.new(Regexp.escape("/users/1.json"))
    f.should =~ Regexp.new(Regexp.escape("/users/2.json"))
  end
  it "generates an index page" do
    @config_file = File.expand_path("../../config/group_endpoints.yml", __FILE__)
    WebServiceDocumenter.generate(@config_file, :output => @output_dir)
    Dir["#{@output_dir}/index.html"].length.should eql 1
    f = File.read("#{@output_dir}/index.html")
    f.should =~ Regexp.new(Regexp.escape("frameset"))
  end
  
  it "generates a Table of Contents page" do
    @config_file = File.expand_path("../../config/group_endpoints.yml", __FILE__)
    WebServiceDocumenter.generate(@config_file, :output => @output_dir)
    Dir["#{@output_dir}/toc.html"].length.should eql 1
    f = File.read("#{@output_dir}/toc.html")
    f.should =~ Regexp.new(Regexp.escape("/users"))
  end
  
  it "generates a README" do
    @config_file = File.expand_path("../../config/group_endpoints.yml", __FILE__)
    WebServiceDocumenter.generate(@config_file, :output => @output_dir)
    Dir["#{@output_dir}/readme.html"].length.should eql 1
    f = File.read("#{@output_dir}/readme.html")
    f.should =~ Regexp.new(Regexp.escape("README"))
  end
  
end
