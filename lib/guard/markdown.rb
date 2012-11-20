require 'guard'
require 'guard/guard'
require 'guard/watcher'
require 'kramdown'

module Guard
  class Markdown < Guard
    class Kramdown
      attr_reader :markdown, :options

      def to_html(markdown, options)
        ::Kramdown::Document.new(markdown, options).to_html
      end
    end

    attr_reader :kram_ops, :markdown_compiler, :compiler_options

    def initialize(watchers=[], options={})
      super
      @options = default_options.merge(options)

      @kram_ops = default_kram_ops
      @kram_ops.update(@options[:kram_ops]) if @options[:kram_ops]

      @compiler_options = default_compiler_options
      @compiler_options.update(@options[:compiler_options]) if @options[:compiler_options]

      @markdown_compiler = @options[:markdown_compiler]
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
        input, output, template = extract_info_for path
        show_info_with input, output, template
        generate_html input, output, template unless @options[:dry_run]
      end
      true
    end

    def extract_info_for(path)
      if path.include? "|"
        return path.split("|")
      end

      [path, name_md2html(path)]
    end

    def name_md2html(path)
      file_name = File.basename(path)
      extension = File.extname(file_name)
      html_file_name = file_name.gsub(extension, '') << ".html"

      original_path = File.dirname(path)
      target_path = if(original_path == ".")
        html_file_name
      else
        File.join(original_path, html_file_name)
      end

      target_path
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

    def generate_html(markdown, output_path, template = nil)
      @kram_ops.update({ :template => template }) unless template.nil?
      html = compile_markdown(markdown)
      target_path = search_or_create_path_for(output_path)
      File.open(target_path, "w") { |f| f.write(html) }
    end

    def compile_markdown(input)
      markdown = File.open(input, "rb").read
      markdown_compiler.to_html(markdown, @kram_ops)
    end

    private
    def default_options
      {
        :convert_on_start => true,
        :dry_run          => false,
        :markdown_compiler => Kramdown.new,
      }
    end

    def default_kram_ops
      default_compiler_options
    end

    def default_compiler_options
      {
        :input => "kramdown",
        :output => "html",
      }
    end

  end
end
