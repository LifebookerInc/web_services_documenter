require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "WebServiceDocumenter::Service" do
  it "takes dynamic urls" do
    s = WebServiceDocumenter::Service.new("localhost", {:endpoint => "/users/{id}.json", :params => {:id => {:example_value => 1, :required => true}}}.with_indifferent_access)
    s.url.should eql "http://localhost/users/1.json"
  end
  
  it "should generate its title from its endpoint" do
    s = WebServiceDocumenter::Service.new("localhost", {:endpoint => "/users/{id}.json", :params => {:id => {:example_value => 1, :required => true}}}.with_indifferent_access)
    s.title.should eql("/users/{id}.json")
  end
  
end
