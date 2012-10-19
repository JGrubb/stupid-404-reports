class FileFetcher

  def initialize(date)
    @cache_dir = "#{File.dirname __FILE__}/cache"
    @date = date
  end

  def get_404
    results = self.read_that_file('404s')
  end

  def get_site_rank
    results = self.read_that_file('rank')
  end

  def read_that_file(str)
    results = []
    if File.exists?("#{@cache_dir}/#{str}/#{@date}")
      results = YAML::load(File.open "#{@cache_dir}/#{str}/#{@date}")
    else
      results = nil
    end
    results
  end
end

class LogParser
  
  def initialize(date)
    @file = "/home/jgrubb/logs/access.log-#{date}"
    @top = []
    @date = date
    @cache_dir = "#{File.dirname __FILE__}/cache"
  end

  def get_404
    results = {} 
    File.open(@file).each_line do |line|
      arr = line.split(' ')
      if arr[8] == '404'
        unless results.has_key?("#{arr[6]}")
          results.merge!("#{arr[6]}" => 1)
        else
          results["#{arr[6]}"] += 1
        end
      end
    end
    @top = Hash[results.sort_by { |k,v| -v }[0..99]]
    File.open("#{@cache_dir}/404s/#{@date}", 'w') do |file|
      file.puts @top.to_yaml
    end
    @top
  end

  def get_site_rank
    results = {}
    File.open(@file).each_line do |line|
      array = line.split(' ')
      site = array[-3].split('=')[1]
      unless results.has_key?(site)
        results.merge!("#{site}" => 1)
      else
        results["#{site}"] += 1
      end
    end
    @top = Hash[results.sort_by { |k,v| -v }[0..99]]
    File.open("#{@cache_dir}/rank/#{@date}", 'w') do |file|
      file.puts @top.to_yaml
    end
    @top
  end
end
