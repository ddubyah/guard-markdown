require 'guard'
require 'guard/guard'
require 'guard/watcher'
require 'Kramdown'

module Guard  
  class Markdown < Guard
    # Your code goes here...
    def initialize(watchers=[], options={})
      super              
      # init stuff here, thx!
    end      
    
    def run_all
      files = Dir.glob("**/*.*")
      targets = Watcher.match_files(self, files) 
      #puts "Running changes on these paths: #{targets}" 
      run_on_change targets
    end
    
    # Called on file(s) modifications
    def run_on_change(paths)
      paths.each do |path|
        input, output = path.split("|") 
        puts "#{input} >> #{output}"
        source = File.open(input,"rb").read 
                                            
        # make sure directory path exists
        reg = /(.+\/).+\.\w+/i
        target_path = output.gsub(reg,"\\1")
        FileUtils.mkpath target_path unless target_path.empty?
        
        doc = Kramdown::Document.new(source, :input => "markdown").to_html
        
        File.open(output, "w") do |f|
          f.puts(doc)
        end
      end
      true
    end
  end
end
