require 'yaml'
require 'sinatra'
require 'date'
load 'models.rb'

class App < Sinatra::Base
  get '/' do
    'hello'
  end

  get '/file' do
    redirect "/file/#{(Date.today - 1).strftime('%Y%m%d')}"    
  end

  get '/site' do
    redirect "/site/#{(Date.today - 1).strftime('%Y%m%d')}"
  end

  get '/file/:date' do
    date = params[:date]
    
    @title = '404s by file'
    @links = Dir["#{File.dirname __FILE__}/cache/by-file/*"].sort.reverse!.take(30)
    # If cached already, serve that.  Else parse.
    @top = FileFetcher.new(date).by_file ? 
      FileFetcher.new(date).by_file : 
      LogParser.new(date).by_file
   
    @date = Date.parse(date).strftime('%b %d, %Y')
    erb :file  
  end

  get '/site/:date' do
    date = params[:date]

    @title = "404s by site"
    @links = Dir["#{File.dirname __FILE__}/cache/by-site/*"].sort.reverse!.take(30)
    # If cached, serve, else parse.
    @top = FileFetcher.new(date).by_site ?
      FileFetcher.new(date).by_site :
      LogParser.new(date).by_site

    @date = Date.parse(date).strftime('%b %d, %Y')
    erb :file
  end
end

App.run!
