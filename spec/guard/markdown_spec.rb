require 'spec_helper'
require 'kramdown'
require "guard/watcher"
require "guard/ui"

describe Guard::Markdown do
  let(:fixtures) { File.expand_path("../../fixtures/some_project", __FILE__) }

  before(:each) do
    @input_paths   = ["input1.md","input2.markdown","dir1/dir2/input3.md"]
    @output_paths = ["output1.html", "output2.html", "dir1/dir2/output3.html"]
    @changed_paths = []
    @input_paths.each_index do |i|
      @changed_paths << "#{@input_paths[i]}|#{@output_paths[i]}"
    end
  end

  describe "::new" do
    it "should be possible to overwrite the default options" do
      subject = Guard::Markdown.new([],{
        :convert_on_start => false,
        :dry_run          => true  })
        subject.options[:convert_on_start].should be false
        subject.options[:dry_run].should be true
    end

    it "should accept additional kramdown options" do
      subject = Guard::Markdown.new([],{
        :kram_ops => { :toc_levels => [2, 3, 4, 5, 6] } })
      subject.kram_ops[:input].should match "kramdown"
      subject.kram_ops[:output].should match "html"
      subject.kram_ops[:toc_levels].should =~ [2, 3, 4, 5, 6]
    end

    context "with default parameters (without arguments)" do
      it "should start with default options" do
        subject.options[:convert_on_start].should be true
        subject.options[:dry_run].should be false
      end

      it "should also start with default kramdown options" do
        subject.kram_ops[:input].should match "kramdown"
        subject.kram_ops[:output].should match "html"
        subject.kram_ops[:toc_levels].should be nil
      end
    end
  end

  describe "start" do
    it "should show a welcome message" do
      Guard::UI.should_receive(:info).with("Guard::Markdown has started watching your files")
      subject.start
    end

    describe "convert_on_start" do
      it "should run all conversions if convert_on_start is true" do
        subject.should_receive(:run_all)
        subject.start
      end

      it "should not convert on start if convert_on_start is false" do
        subject = Guard::Markdown.new([],{ :convert_on_start => false })
        subject.should_not_receive(:run_all)
        subject.start
      end
    end

  end

  describe "run_on_change" do
    it "should read the changed files markdown and convert it to html " do
      @input_paths.each_index do |i|
        #mock file read
        file_double = double()
        file_double.should_receive(:read).and_return("#Title")
        File.should_receive(:open).with(@input_paths[i],"rb").and_return(file_double)

        mock_kramdown("#Title").should_receive(:to_html).and_return("<h1>Title</h1>")

        #test info messages
        Guard::UI.should_receive(:info).with("#{@input_paths[i]} >> #{@output_paths[i]}")

        #mock file write
        file_out = double()
        target_path = File.dirname @output_paths[i]
        FileUtils.should_receive(:mkpath).with(target_path)
        File.should_receive(:open).with(@output_paths[i], "w").and_return(file_out)

        #TODO Not sure how to test actually writing to the file

      end
      subject.run_on_change(@changed_paths)
    end

    describe "dry run" do
      subject { Guard::Markdown.new([],{ :dry_run=> true  }) }
      it "should not permorm a conversion on a dry run" do
        FileUtils.should_not_receive(:mkpath)
        File.should_not_receive(:open)
        Kramdown::Document.should_not_receive(:new)
        Guard::UI.should_receive(:info).exactly(3).times
        subject.run_on_change(@changed_paths)
      end
    end

    describe "with a template file" do
      it "should use the template when converting the source file" do
        file_double = double()
        file_double.should_receive(:read).and_return("#Title")
        File.should_receive(:open).with("input.md","rb").and_return(file_double)
        kram_doc = double()
        kram_doc.should_receive(:to_html)
        Kramdown::Document.should_receive(:new).with("#Title", :input => "kramdown", :output => "html", :template => "template.html.erb").and_return(kram_doc)

        file_out = double()
        FileUtils.should_receive(:mkpath)
        File.should_receive(:open).with("output.html", "w").and_return(file_out)

        Guard::UI.should_receive(:info).with("input.md >> output.html via template.html.erb")

        subject.run_on_change(["input.md|output.html|template.html.erb"])
      end
    end
  end

  describe "with a template file and additional kramdown options" do
    subject { Guard::Markdown.new([],{ :kram_ops => { :toc_levels => [2, 3, 4, 5, 6] } }) }

    it "should use the additional kramdown options and the template when converting the source file" do
      file_double = double()
      file_double.should_receive(:read).and_return("#Title")
      File.should_receive(:open).with("input.md","rb").and_return(file_double)
      kram_doc = double()
      kram_doc.should_receive(:to_html)

      Kramdown::Document.should_receive(:new).with("#Title", :input => "kramdown", :output => "html",
          :toc_levels => [2, 3, 4, 5, 6], :template => "template.html.erb").and_return(kram_doc)

      file_out = double()
      FileUtils.should_receive(:mkpath)
      File.should_receive(:open).with("output.html", "w").and_return(file_out)

      Guard::UI.should_receive(:info).with("input.md >> output.html via template.html.erb")

      subject.run_on_change(["input.md|output.html|template.html.erb"])
    end
  end

  describe "run_all" do
    #mock Guard.watcher
    let(:mock_watch) { double }
    subject { Guard::Markdown.new(mock_watch) }

    it "should call run_on_change for all matching paths" do
      #mock Dir
      Dir.should_receive(:glob).with("**/*.*").and_return(@input_paths)


      #Guard::Watcher should handle the matching and path manipulation
      ## TODO the following line throws an uninitilizd const error Guard::Guard::Watcher -> don't know why. It'll have to go untested for now
      Guard::Watcher.should_receive(:match_files).with(subject, @input_paths).and_return(@changed_paths)

      subject.should_receive(:run_on_change).with(@changed_paths)

      subject.run_all
    end
  end

  describe "#extract_info_for" do
    context "when | is used to define output [and template]" do
      it "return Readme.md|Readme.html|template.html.erb as [Readme.md, Readme.html, template.html.erb]" do
        result = subject.extract_info_for "Readme.md|Readme.html|template.html.erb"
        expect(result).to be_eql ["Readme.md", "Readme.html", "template.html.erb"]
      end
    end

    context "without pipes" do
      it "return Readme.md as [Readme.md, Readme.html]" do
        expect(subject.extract_info_for "Readme.md" ).to be_eql ["Readme.md", "Readme.html"]
      end

      it "return some/dir/Readme.md as [some/dir/Readme.md, some/dir/Readme.html]" do
        result = subject.extract_info_for "some/dir/Readme.md"
        expect(result).to be_eql ["some/dir/Readme.md", "some/dir/Readme.html"]
      end
    end

    context "with output_dir option" do
      subject { Guard::Markdown.new([], { output_dir: "omg_test" }) }

      it "return omg_test/some/dir/README.md as [some/dir/README.md, omg_test/some/dir/Readme.html]" do
        result = subject.extract_info_for "some/dir/Readme.md"
        expect(result).to be_eql ["some/dir/Readme.md", "omg_test/some/dir/Readme.html"]
      end
    end
  end

  describe "#compile_markdown" do
    let(:markdown_file) { File.join fixtures, "README.md" }
    let(:generated_file) { File.join fixtures, "README.html" }

    context "providing a markdown compiler" do
      let(:compiler) { double }
      subject { Guard::Markdown.new([], markdown_compiler: compiler) }

      it "should allow to change markdown compiler with option" do
        expect(subject.markdown_compiler).to be compiler
      end

      it "should invoke #to_html(input) on a markdown compiler" do
        compiler.should_receive(:to_html).with(IO.read(markdown_file), subject.compiler_options)
        subject.compile_markdown(markdown_file)
      end

    end
  end

  describe "#generate_html" do
    let(:markdown_file) { File.join fixtures, "README.md" }
    let(:generated_file) { File.join fixtures, "README.html" }

    it "should generate a fixtures/README.html based on fixtures/README.md" do
      subject.generate_html(markdown_file, generated_file)
      expect(File.exist?(generated_file)).to be_true
    end

    after { FileUtils.rm_rf(generated_file) }
  end

end

private

def mock_kramdown text
   kram_doc = double()
  Kramdown::Document.should_receive(:new).with(text, :input => "kramdown", :output=> "html").and_return(kram_doc)
  kram_doc
end
