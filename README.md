# Guard::Markdown #
Markdown guard will watch your markdown documents for changes and convert them to lovely, semantic html. Yay!

## Install ##

You're going to need [Guard](https://github.com/guard/guard) too.

Install with
	
	$ gem install guard-markdown
	
Or add it to your Gemfile

	gem 'guard-markdown'
	
## Usage ##

Go see the [Guard usage doc](https://github.com/guard/guard#readme) for general instructions

## The Guardfile - where the magic happens
	
The Guardfile is where you define your desired input and output paths.
Create it with:

	$ guard init markdown
	
Then tweak the watch statements to your hearts content. It'll look a lot like this:

```
guard 'markdown', output_dir: 'tmp' do
  watch(%r{^(.*)(\.md|\.markdown)$})
end
```
The guard statement defines which guard your configuring and sets any optional parameters.

* :output_dir - indicates where the generated html files will stay.
* :convert_on_start - if true will run all conversions when you start the guard. Defaults to true
* :dry_run - if true won't actually run the conversion process, but it will output the files being watched and the file it would write to. Use it to tweak your watch statements and when you're happy set it to false.
* :compiler_options - use it to pass any additional options for the markdown
  compiler (kramdown by default)

For example to generate a table of contents consisting of headers 2 through 6 first make sure that something like the following is in your markdown source file. This serves as a placeholder which will be replaced with the table of contents. See: [Automatic Table of Contents Generation](http://kramdown.rubyforge.org/converter/html.html#toc).

    * table of contents
    {:toc}

Then include the following in the start of your guard markdown block:

    :markdown_compiler => { :toc_levels =>  [2, 3, 4, 5, 6]}

* :markdown_compiler - allow you to replace the kramdown compiler by another one
  that you may prefer.

If you really want, you can use some regular expressions in your watch statement
to tweak the paths of your inputs and ouputs. Look this example:
	watch (/source_dir\/(.+\/)*(.+\.)(md|markdown)/i) { |m| "source_dir/#{m[1]}#{m[2]}#{m[3]}|output_dir/#{m[1]}#{m[2]}html|optional_template.html.erb"}
			 
			^ ------ input file pattern -----------  ^        ^ ---- input file path -------- ^|^ ----- output file path ---^|^ --- template path ---- ^
	
The "input file pattern" is a regular expression that is used to determine which files are watched by the guard. It'll be applied recursively to all files and folders starting in the current working directory. 

Any matches are passed into the block and used to construct the conversion command. The conversion command is a string containing the path to the source file and the desired path to the output file separated by a "|". 
You can also provide an optional template file. This file, if provided will be used by kramdown to wrap the converted output. 
The template file is _typically_ an html file, and you define where the converted content will be placed by adding <%= @body %> in the desired location. e.g.

 <div id = "main">
	<%= @body %>
 </div>
	
I hope that makes sense :)

## Have Fun ##

Go see the other [great guards available](https://github.com/guard/guard/wiki/List-of-available-Guards)

Oh yeah, I'm using [Kramdown](http://kramdown.rubyforge.org/) for the conversion engine. So if you want to know what markdown syntax it supports, [go here](http://kramdown.rubyforge.org/syntax.html)

# TODO #

* Allow the conversion of more doc types using Kramdown

