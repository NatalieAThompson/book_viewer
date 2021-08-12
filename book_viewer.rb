require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"

def load_contents
  @contents = File.readlines("data/toc.txt")
  @contents
end

get "/" do
  load_contents
  erb :home

end

get "/:something" do |n|
  @title = n
  load_contents
  erb :home
end

get "/chapter/1" do
  @title = "Chapter 1"
  load_contents
  @chapter = File.read("data/chp1.txt").split("\n\n")
  p @chapter
  erb :chapter
end


