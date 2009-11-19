require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "KissboxGomGateway" do
  it "should require service" do
    Kissbox::Service.should_not == nil
  end
end
