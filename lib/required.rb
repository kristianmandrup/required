def ruby_files path
  location = Required.new(path).location
  files = []
  FileUtils.cd location do
    files = FileList.new('**/*.rb') 
    files.select! {|f| (f =~ /[^\.]*.rb$/) == 0 }
  end
  files
end

class Required
  attr_accessor :location
  
  def initialize location
    @location = File.dirname(location)
  end
  
end
