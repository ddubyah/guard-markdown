require 'guard'
require 'guard/guard'
require 'guard/watcher'
require 'Kramdown'

module Guard  
  class Markdown < Guard
    # Your code goes here...
    def initialize(watchers=[], options={})
      super              
      @options = {
        :convert_on_start => true,
        :dry_run          => false
      }.update(options)
    end         
    
    def start
      UI.info("Guard::Markdown has started watching your files")
      run_all if @options[:convert_on_start]
    end
    
    def run_all
      files = Dir.glob("**/*.*")
      targets = Watcher.match_files(self, files)  
      run_on_change targets
    end
    
    # Called on file(s) modifications
    # TODO  - this method does far too much. Must refactor to allow
    #       - for better testing
    def run_on_change(paths)
      paths.each do |path|
        input, output, template = path.split("|")
        info = "#{input} >> #{output}"
        info = "#{info} via #{template}" unless template.nil? 
        UI.info info 
        unless @options[:dry_run]
          source = File.open(input,"rb").read                        
                                            
          # make sure directory path exists
          reg = /(.+\/).+\.\w+/i
          target_path = output.gsub(reg,"\\1")
          FileUtils.mkpath target_path unless target_path.empty?
          
          kram_ops = { :input => "markdown" }
          kram_ops.update({ :template => template }) unless template.nil?
          
          doc = Kramdown::Document.new(source, kram_ops).to_html
                   
        
          File.open(output, "w") do |f|
            f.write(doc)
          end
        end
      end
      true
    end
  end
end
