require 'yaml'
require 'sinatra'
require 'date'
load 'models.rb'

class App < Sinatra::Base
  get '/' do
    @links = []
    erb :home
  end

  get '/:method' do
    method = params[:method]
    redirect "/#{method}/#{(Date.today - 1).strftime('%Y%m%d')}"    
  end

  get '/:method/:date' do
    date = params[:date]
    method = params[:method].to_sym

    @title = '404s by file'
    @links = Dir["#{File.dirname __FILE__}/cache/#{method.to_s}/*"].sort.reverse!.take(30)
    # If cached already, serve that.  Else parse.
    @top = FileFetcher.new(date).send(method) ? 
      FileFetcher.new(date).send(method) :
      LogParser.new(date).send(method)
   
    @date_toi = date.to_i
    @date = Date.parse(date).strftime('%b %d, %Y')
    erb :file  
  end
end

App.run!
