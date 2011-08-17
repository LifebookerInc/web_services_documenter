require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "WebServiceDocumenter::ServiceCollection" do
  it "should generate its title from its endpoint" do
    s = WebServiceDocumenter::ServiceCollection.new("/users")
    s << WebServiceDocumenter::Service.new("localhost", {:endpoint => "/users/{id}.json", :params => {:id => {:example_value => 1, :required => true}}}.with_indifferent_access)
    s.title.should eql "/users"
  end
  
end
