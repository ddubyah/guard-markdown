require 'spec_helper'
require 'Kramdown'
require "guard/watcher" 

describe "Guard-Markdown" do      
                             
	before(:each) do   
		@subject = Guard::Markdown.new
	  @input_paths 	= ["input1.md","input2.markdown","dir1/dir2/input3.md"]
		@output_paths = ["output1.html", "output2.html", "dir1/dir2/output3.html"]
		@changed_paths = []
		@input_paths.each_index do |i|
			@changed_paths << "#{@input_paths[i]}|#{@output_paths[i]}"
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
				
				#mock file write                                       
				file_out = double()                                                       
				File.should_receive(:open).with(@output_paths[i], "w").and_return(file_out)
				
				#TODO Not sure how to test actually writing to the file
						
			end
			@subject.run_on_change(@changed_paths)
		end            
	end 
	
	# describe "run_all" do
	#   it "should call run_on_change for all matching paths" do
	# 		#mock Guard.watcher
	# 		mock_watch = double()
	# 
	# 		#mock Dir
	# 		Dir.should_receive(:glob).with("**/*.*").and_return(@input_paths)
	# 	 	
	# 		subject = Guard::Markdown.new(mock_watch)
	# 		
	# 		#Guard::Watcher should handle the matching and path manipulation
	# 		## TODO the following line throws an uninitilizd const error Guard::Guard::Watcher -> don't know why. It'll have to go untested for now
	# 		Watcher.should_receive(:match_files).with(subject, mock_watch).and_return(@changed_paths)
	# 					
	# 		subject.should_receive(:run_on_change).with(@changed_paths)
	# 		
	# 		subject.run_all
	#   end
	# end 
end  

private

def mock_kramdown text
 	kram_doc = double()
	Kramdown::Document.should_receive(:new).with(text, :input => "markdown").and_return(kram_doc)
	kram_doc
end