require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Required" do
  @folder = File.dirname(__FILE__)
  context "current folder: #{@folder}"  do
    describe '#' do
      it "should list" do
        res = ruby_files(__FILE__).except('except_me')
        res.should include(File.basename(__FILE__))
        res.should_not include('not_me.erb.rb')        
        res.should_not include('except_me.rb')                
      end
    end    
  end
end
