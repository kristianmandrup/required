require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class String
  def remove_rb
    self.sub!('.rb', '')
  end  
end

def path *args
  File.join args
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
        res = ruby_files('spec', __FILE__).except_files('except_me')
        res.should include(path dir, File.basename(__FILE__))
        res.should_not include(path dir, 'not_me.erb.rb')
        res.should_not include(path dir, 'except_me.rb')
        res.should include(path dir, 'except_also_me.rb') # not in except list
      end

      it "should list all 'pure' ruby files except one file using block DSL" do
        res = ruby_files('spec', __FILE__) do
          except_files('except_me')
        end
        res.should include(path dir, File.basename(__FILE__))
        res.should_not include(path dir, 'not_me.erb.rb')
        res.should_not include(path dir, 'except_me.rb')
        res.should include(path dir, 'except_also_me.rb') # not in except list
      end

      
      it "should list all 'pure' ruby files except two file" do
        res = ruby_files('spec', __FILE__).except_files('except_me', 'except_also_me')
        res2 = ruby_files('spec', __FILE__).except_files('except_me').except_files('except_also_me')        
        res2.should == res
        res.should include(path dir, File.basename(__FILE__))
        res.should_not include(path dir, 'not_me.erb.rb')
        res.should_not include(path dir, 'except_me.rb')
        res.should_not include(path dir, 'except_also_me.rb')
      end
            
      it "should list required files" do
        res = ruby_files('spec', __FILE__).except_files('except_me').require_files.require! :get
        res2 = ruby_files('spec', __FILE__).except_files('except_me').require_files :get
        res2.should == res        
        res.should include(path dir, File.basename(__FILE__).remove_rb)
        res.should_not include(path dir, 'not_me.erb')
        res.should_not include(path dir, 'except_me')
        res.should include(path dir, 'except_also_me')
      end

      it "should list only required files" do
        res = ruby_files('spec', __FILE__).only_files(/.*only.*/).require_files.require! :get
        res.should_not include(path dir, File.basename(__FILE__).remove_rb)
        res.should include(path dir, 'only_me')
        res.should_not include(path dir, 'except_me')
        res.should_not include(path dir, 'except_also_me')
      end

      it "should list all 'pure' ruby files except one subfolder using block DSL" do
        res = ruby_files('spec', __FILE__, :recursive => :full) do
          except_folders('not_this_folder')
        end.require_files.require! :get
        res.should include(path dir, File.basename(__FILE__).remove_rb)
        res.should include(path dir, 'this_folder', 'yes_me')
      end

      it "should list all 'pure' ruby files except one subfolder using block DSL" do
        res = ruby_files('spec', __FILE__, :recursive => :full) do
          only_folders('this_folder')
        end.require_files.require! :get
        res.should include(path dir, File.basename(__FILE__).remove_rb)
        res.should include(path dir, 'this_folder', 'yes_me')
        res.should_not include(path dir, 'not_this_folder', 'sub_not_me')
      end


    end    
  end
end
