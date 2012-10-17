require 'yaml'
require 'sinatra'
require 'date'

class App < Sinatra::Base
  get '/' do
    'hello'
  end

  get '/:id' do
    
    file = "/home/jgrubb/logs/#{params[:id]}"
    dir = File.dirname(__FILE__)

    @links = Dir["#{dir}/cache/*"].sort.reverse!.take(30)

    if File.exists?("#{dir}/cache/#{params[:id]}")
      @top_ten = YAML::load(File.open "#{dir}/cache/#{params[:id]}")
    else
      hash = {}
      total = 0

      # Read the log file and searchf or 404s
      File.open("#{file}").each_line do |line|
        arr = line.split(' ')
        if arr[8] == '404'
          total += 1
          unless hash.has_key?("#{arr[6]}")
            hash.merge!("#{arr[6]}" => 1)
          else
            hash["#{arr[6]}"] += 1
          end
        end
      end
      
      #Populate @top_ten with top ten 404 errors
      @top_ten = Hash[hash.sort_by { |k,v| -v }[0..9]]

      File.open("#{dir}/cache/#{params[:id]}", 'w') do |file|
        file.puts @top_ten.to_yaml
      end
    end 
    erb :file  
  end
end

App.run!
