require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class String
  def remove_rb
    self.sub!('.rb', '')
  end  
end

def path dir, file
  File.join dir, file
end

def current_folder
  File.dirname(__FILE__)  
end

describe "Required" do
  let (:folder) { current_folder }
  let (:dir)    { 'spec/required' }
  
  context "current folder: #{current_folder}"  do
    describe '#' do
      it "should list all 'pure' ruby files" do
        res = ruby_files('spec', __FILE__)
        res.should include(path dir, File.basename(__FILE__) )
        res.should_not include(path dir, 'not_me.erb.rb' )
      end

      it "should list all 'pure' ruby files except one file" do
        res = ruby_files('spec', __FILE__).except('except_me')
        res.should include(path dir, File.basename(__FILE__))
        res.should_not include(path dir, 'not_me.erb.rb')
        res.should_not include(path dir, 'except_me.rb')
        res.should include(path dir, 'except_also_me.rb') # not in except list
      end

      it "should list all 'pure' ruby files except one file using block DSL" do
        res = ruby_files('spec', __FILE__) do
          except('except_me')
        end
        res.should include(path dir, File.basename(__FILE__))
        res.should_not include(path dir, 'not_me.erb.rb')
        res.should_not include(path dir, 'except_me.rb')
        res.should include(path dir, 'except_also_me.rb') # not in except list
      end

      
      it "should list all 'pure' ruby files except two file" do
        res = ruby_files('spec', __FILE__).except('except_me', 'except_also_me')
        res2 = ruby_files('spec', __FILE__).except('except_me').except('except_also_me')        
        res2.should == res
        res.should include(path dir, File.basename(__FILE__))
        res.should_not include(path dir, 'not_me.erb.rb')
        res.should_not include(path dir, 'except_me.rb')
        res.should_not include(path dir, 'except_also_me.rb')
      end
            
      it "should list required files" do
        res = ruby_files('spec', __FILE__).except('except_me').require_files.require! :get
        res2 = ruby_files('spec', __FILE__).except('except_me').require_files :get
        res2.should == res        
        res.should include(path dir, File.basename(__FILE__).remove_rb)
        res.should_not include(path dir, 'not_me.erb')
        res.should_not include(path dir, 'except_me')
        res.should include(path dir, 'except_also_me')
      end

    end    
  end
end
