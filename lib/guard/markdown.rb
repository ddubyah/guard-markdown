require 'guard'
require 'guard/guard'
require 'guard/watcher'
require 'kramdown'

module Guard
  class Markdown < Guard

    attr_reader :kram_ops
    def initialize(watchers=[], options={})
      super
      @options = default_options.update(options)
      @kram_ops = default_kram_ops
      @kram_ops.update(@options[:kram_ops]) if @options[:kram_ops]
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
    def run_on_change(paths)
      paths.each do |path|
        input, output, template = path.split("|")
        show_info_with input, output, template
        unless @options[:dry_run]
          @kram_ops.update({ :template => template }) unless template.nil?
          doc = compile_markdown(input)
          output_path = search_or_create_path_for(output)
          generate_output output_path, doc
        end
      end
      true
    end

    def show_info_with(input, output, template)
      info = "#{input} >> #{output}"
      info = "#{info} via #{template}" unless template.nil?
      UI.info info
    end

    def search_or_create_path_for(output)
      target_path = File.dirname output
      FileUtils.mkpath target_path
      output
    end

    def compile_markdown(input)
      source = File.open(input,"rb").read
      Kramdown::Document.new(source, @kram_ops).to_html
    end

    def generate_output(output_path, doc)
      File.open(output_path, "w") do |f|
        f.write(doc)
      end
    end

    private
    def default_options
      {
        :convert_on_start => true,
        :dry_run          => false,
      }
    end

    def default_kram_ops
      {
        :input => "kramdown",
        :output => "html",
      }
    end

  end
end
