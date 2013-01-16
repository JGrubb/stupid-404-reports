require 'yaml'
require 'sinatra/base'
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

  get '/site_by_file/:site/:date' do
    site = params[:site]
    date = params[:date]

    @title = "#{site} on #{Date.parse(date)}"
    @links = [] 
    @top = FileFetcher.new(date).site_by_date(site) ?
      FileFetcher.new(date).site_by_date(site) :
      LogParser.new(date).site_by_date(site)
    @date_toi = date.to_i
    @date = Date.parse(date).strftime('%b %d, %Y')
    erb :site_by_file
  end

#  get '/site_by_file/:site/:date/:file' do
#    site = params[:site]
#    date = params[:date]
#    file = params[:file]
#
#    @title = "Referrers - #{site} - #{file}"
#    @links = []
#    @top = LogParser.new(date).referrer(site, file)
#    @date_toi = date.to_i
#    @date = Date.parse(date).strftime('%b %d, %y')
#    erb :standard
#  end

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

    erb(method.to_sym)
  end

  get '/:method/:date/:ip' do

  end

end

App.run!
