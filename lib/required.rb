def ruby_files base_path, path, options = {}, &block
  required = Required.new(base_path, path)
  files = []       
  dir = File.dirname path
  FileUtils.cd dir do             
    glob = Required.glob(options)
    files = FileList.new(glob) 
    Required.extend_files(files).extend(FileString)
    files.select_ruby_files!
    files.prefix_with_path! required.location
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
    rel_path = relative_path(base_path, path)
    @location = File.dirname(rel_path) 
  end

  def self.glob options
    case options[:recursive]
    when :full
      '**/*.rb'    
    when :single
      '*/*.rb'
    else
      '*.rb'
    end
  end
  
  def self.extend_files files
    files.extend(FileListExtension)
    files.each{|f| f.extend(FileString)}
  end    
  
  protected

  def relative_path base_path, path 
    last_part_path = path.gsub /(\S*?)#{Regexp.escape(base_path)}\/(.*?)/, '\2'
    File.join(base_path, last_part_path)
  end
  
end  

module FileListExtension

  def prefix_with_path! location                      
    
    self.map! do |f| 
      File.join(location, f).extend(FileString) 
    end
    self          
  end

  def require! mode = :require
    self.each{|f| f.handle_file mode}      
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

  def only *only_files
    self.select! do |file| 
      file.matches_any only_files
    end
    self
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
  
  def matches_any match_files
    match_files.any? {|match_file| match?(self, match_file)}    
  end

  def match? file, match_file
    case match_file
    when String 
      (file =~ /#{Regexp.escape(match_file)}.rb$/) != nil
    when Regexp
      (file =~ match_file) != nil      
    else
      raise ArgumentError, "File matcher must be either a String or RegExp"
    end
  end

end  