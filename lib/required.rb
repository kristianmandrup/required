require 'stringio'

def ruby_files base_path, path, options = {}, &block
  required = Required.new(base_path, path)
  stdout = options[:stdout] if options[:stdout]
  required.stdout = stdout
  files = []       
  dir = File.dirname path
  FileUtils.cd dir do |dir|            
    glob = Required.glob(options)
    files = FileList.new(glob) 
    Required.extend_files(files, required)
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
  attr_accessor :location, :stdout
  
  def initialize base_path, path
    rel_path = relative_path(base_path, path)
    @location = File.dirname(rel_path) 
  end

  def self.glob options
    case options[:recursive]
    when :full
      '**/*.rb'    
    when :single
      ['*/*.rb', '*.rb']
    else
      '*.rb'
    end
  end
  
  def self.extend_files files, required
    files.extend(FileListExtension).required = required 
    files.map! do |f| 
      f.extend(FileString)
      f.required = required
      f
    end 
    files
  end    
  
  protected

  def relative_path base_path, path 
    last_part_path = path.gsub /(\S*?)#{Regexp.escape(base_path)}\/(.*?)/, '\2'
    File.join(base_path, last_part_path)
  end
  
end  

module FileListExtension

  attr_accessor :required

  def prefix_with_path! location    
    self.map! do |f| 
      f = File.join(location, f).extend(FileString)
      f.required = required       
      f
    end
    self          
  end

  def strip_file_ext mode = nil
    self.map!{|f| f.remove_rb }
    if mode
      self.action mode
    else
      self
    end
  end

  def select_ruby_files!
    self.select! {|f| (f =~ /[^\.]*.rb$/) == 0 }
    self
  end

  def except_folders *reject_folders    
    self.reject! do |file| 
      file.matches_any_folder reject_folders
    end
    self
  end

  
  def except_files *reject_files
    self.reject! do |file| 
      file.matches_any reject_files
    end
    self
  end

  def only_folders *only_folders
    self.select! do |file| 
      !file.inside_a_folder? || file.matches_any_folder(only_folders)
    end
    self
  end

  def only_files *only_files
    self.select! do |file| 
      file.matches_any only_files
    end
    self
  end

  protected
  
  def action mode = :require
    self.each{|f| f.handle_file mode}      
  end
  
      
end

module FileString  

  attr_accessor :required

  def handle_file mode = nil
    stdout = required.stdout    
    case mode
    when Hash      
      case stdout
      when StringIO
        stdout.write display_text(mode)
      else
        puts "#{mode[:display]} '#{self}'" if mode[:display]
        puts self if !mode[:display]  
      end
        
    when :display    
      stdout.puts self
    when :require
      require self
    when :require
      load self
    else
      self
    end
  end

  def display_text mode
    mode[:display] ? "#{mode[:display]} '#{self}'\n" : "#{self}\n"    
  end

  def remove_rb
    self.sub!('.rb', '')
  end  
  
  def matches_any match_files
    match_files.any? {|match_file| match? match_file }    
  end

  def matches_any_folder match_folders  
    match_folders.any? {|match_folder| match_folder? match_folder }
  end

  def inside_a_folder?
    return true if (self =~ /#{Regexp.escape(required.location)}\/(.*?)\//) != nil      
  end

  protected

  def match? match_file
    case match_file
    when String
      (self =~ /#{Regexp.escape(match_file)}.rb$/) != nil
    when Regexp
      (self =~ /#{match_file.source}.rb$/) != nil
    else
      raise ArgumentError, "File matcher must be either a String or RegExp"
    end
  end

  def match_folder? match_folder                
    case match_folder
    when String
      (self =~ /#{Regexp.escape(required.location)}\/#{Regexp.escape(match_folder)}\//) != nil
    when Regexp
      (self =~ /#{Regexp.escape(required.location)}\/#{match_folder.source}\//) != nil
    else
      raise ArgumentError, "File matcher must be either a String or RegExp"
    end
  end


end  