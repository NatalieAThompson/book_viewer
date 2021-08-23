require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"

before do
  @contents = File.readlines("data/toc.txt")
end

helpers do
  def in_paragraphs(text)
    text = text.split("\n\n")
    text.map.with_index do |paragraph, index|
      "<p id=\"a#{index}\">" + paragraph + "</p>"
    end.join
  end

  def bold_word(para, word_to_bold)
    para.gsub!(word_to_bold, "<strong>#{word_to_bold}</strong>")
  end
end

not_found do
  redirect "/"
end

get "/" do
  @title = "Book Viewer"

  erb :home
end

get "/chapter/:number" do |number|
  # redirect "/" unless (1..@contents.size).include?(number)
  @title = "Chapter #{number}: #{@contents[number.to_i - 1]}"
  @chapter = File.read("data/chp#{number}.txt")

  erb :chapter
end

get "/search" do
  @chapters = Dir.children("data")
  @chapters.delete("toc.txt")

  @chapters.sort_by! do |title|
    title.delete("^0123456789").to_i
  end

  @search_term = params[:query] || false

  @book = {}

  @contents.each.with_index do |title, index|
    @book[title] = { :number => index + 1, :paragraphs => {}, :selected => false}
  end                           #book will have a key for every chapter

  @chapters.select! do |file|
    File.read("data/" + file).include?(params[:query]) if params[:query]
  end

  unless @chapters.empty?
    @chapters.map! do |file|
      file.delete('^0123456789')
    end
  end

  # p @paragraphs #a nested array of chapters with the matching word. Each array element lines up with the @chapter_names array
  #loop through books if value[:number] is found in @chapters selected = true; if selected is true then add paragraphs.
  if @search_term
    @book.each do |key, value|
      if @chapters.include?(value[:number].to_s)
        value[:selected] = true

        #Add chapters here
        chapter = File.read("data/chp#{value[:number]}.txt")
        chapter = in_paragraphs(chapter).split("/p>")

        chapter.each do |paragraph|
          if paragraph.include?(params[:query])
            id = paragraph.scan(/id="(.+?)"/).flatten[0]
            para = paragraph.delete("</>")
            para = para.sub("p", "")
            para = para.sub(/id="(.+?)"/, "")
            value[:paragraphs].merge!(id => para)
          end
        end
      end
    end
  end

  #how do I look through the chapters?
    # I need to read the file that the chapter belongs with
      # To do that I need to File.read("data/chp#{value[:number]}.txt") set it to `chapter` local variable
    # I need to loop format the page properly
      # To do that I can pass the page through the in_paragraphs method.
    # I need to split on the "/p>" for each p element
    # loop through each element of the chapters array
      # if the chapter includes the seach term then
        #Format the paragraph
          # The paragraph can't have the <p> </p> tags but I need to keep the id attribute value
          # To find the id value use scan to capture the value id="(.)"
          # Then capture the string between > </
        #add it to the paragraphs hash
          #The hash key should be the id attribute value
          #The value should be the paragraph text formated properly

  erb :search
end


=begin
So I have a @chapters array that has a list of files, ex chap1.txt etc
For each one of those chapters I need to loop through it and create a hash.
  - How do I want my hash to look?
    book = { "Name of book"=> { :number => number of book, :paragraphs => [] }
          }


=end