require 'yaml'
require 'sinatra'
require 'date'
load 'models.rb'

class App < Sinatra::Base
  get '/' do
    'hello'
  end

  get '404s/' do
    
  end

  get '/404s/:date' do
    date = params[:date]

    # If cached already, serve that.  Else parse.
    @top = FileFetcher.new(date).get_404 ? 
      FileFetcher.new(date).get_404 : 
      LogParser.new(date).get_404
     
    erb :file  
  end

  get '/site-rank/:date' do
    date = params[:date]

    @top = FileFetcher.new(date).get_site_rank ?
      FileFetcher.new(date).get_site_rank :
      LogParser.new(date).get_site_rank

    erb :file
  end
end

App.run!
