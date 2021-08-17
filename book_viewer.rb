require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"

before do
  @contents = File.readlines("data/toc.txt")
end

helpers do
  def in_paragraphs(array)
    array.map do |paragraph|
      "<p>" + paragraph.delete("\n") + "</p>"
    end.join
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
  redirect "/" unless (1..@contents.size).include? number
  @title = "Chapter #{number}: #{@contents[number.to_i - 1]}"
  @chapter = File.read("data/chp#{number}.txt").split("\n\n")

  erb :chapter
end


