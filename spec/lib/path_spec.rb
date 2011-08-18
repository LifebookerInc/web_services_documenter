require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "WebServiceDocumenter" do
  
  before :all do
    # make sure these are included - they should be in the parent anyway
    Object.const_set("PathClass", Class.new(WebServiceDocumenter::Service))
    PathClass.send(:include, WebServiceDocumenter::Path)
    Object.const_set("CollectionPathClass", Class.new(WebServiceDocumenter::ServiceCollection))
    CollectionPathClass.send(:include, WebServiceDocumenter::Path)
  end

  it "should give a path relative to the directory of the documentation for a single Service" do
    s = PathClass.new("localhost", {:endpoint => "/users/{id}.json", :params => {:id => {:example_value => 1, :required => true}}}.with_indifferent_access)
    s.path.should eql("users/id.html")
  end
  
  it "should give a path relative to the directory of the documentation for multiple Services" do
    s = CollectionPathClass.new("/users")
    s << PathClass.new("localhost", {:endpoint => "/users/{id}.json", :params => {:id => {:example_value => 1, :required => true}}}.with_indifferent_access)
    s.path.should eql "users.html"
  end
  
end