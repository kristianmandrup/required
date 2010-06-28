def ruby_files base_path, path, &block
  location = Required.new(base_path, path).location
  files = []
  FileUtils.cd location do
    files = FileList.new('**/*.rb') 
    Required.extend_files(files).extend(FileString)
    files.select_ruby_files!
  end 
  if block
    block.arity < 1 ? files.instance_eval(&block) : block.call(files)
  else
    files
  end    
end

class Required
  attr_accessor :location
  
  def initialize base_path, path
    @location = File.dirname(relative_path(base_path, path))
  end
  
  def self.extend_files files
    files.extend(FileListExtension)
    files.each{|f| f.extend(FileString)}
  end    
  
  protected

  def relative_path base_path, path    
    last_part_path = path.gsub /(.*?)#{Regexp.escape(base_path)}(.*?)/, '\2'  
    last_part_path.split('/').reject {|f| f == ""}.join('/')    
  end
  
end  

module FileListExtension

  def require! mode = :require
    iterate_all do |f|
      f.handle_file mode
    end       
  end

  def require_files mode = nil
    self.map!{|f| f.remove_rb }
    if mode
      self.require! mode
    else
      self
    end
  end

  def select_ruby_files!
    self.select! {|f| (f =~ /[^\.]*.rb$/) == 0 }
    self
  end
  
  def except *reject_files
    self.reject! do |file| 
      file.matches_any reject_files
    end
    self
  end
     
  protected

  def iterate_all
    self.each{|f| yield f}    
  end
  
end

module FileString  

  def handle_file mode = :require
    case mode
    when :display    
      puts self
    when :require
      require self
    when :get
      self
    else
      raise ArgumentError, "Mode argument must be :display, :show or :get"
    end
  end

  def remove_rb
    self.sub!('.rb', '')
  end  
  
  def matches_any reject_files
    reject_files.any? {|reject_file| reject?(self, reject_file)}    
  end

  def reject? file, reject_file
    (file =~ /#{Regexp.escape(reject_file)}.rb$/) != nil
  end

end  