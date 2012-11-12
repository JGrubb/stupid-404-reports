class FileFetcher

  def initialize(date)
    @cache_dir = "#{File.dirname __FILE__}/cache"
    @date = date
  end

  def by_file
    self.read_that_file 'by_file'
  end

  def by_site
    self.read_that_file 'by_site'
  end

  def site_by_date(site)
    self.read_that_file('site_by_date', site)
  end

  def method_missing(m, *args)
    if results = self.read_that_file(m)
    else
      super
    end
  end

  def read_that_file(str, site = nil)
    results = []
    if site
      if File.exists?("#{@cache_dir}/#{str}/#{site}-#{@date}")
        results = YAML::load(File.open "#{@cache_dir}/#{str}/#{site}-#{@date}")
      else
        results = nil
      end
    else
      if File.exists?("#{@cache_dir}/#{str}/#{@date}")
        results = YAML::load(File.open "#{@cache_dir}/#{str}/#{@date}")
      else
        results = nil
      end
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

  def by_file
    results = {} 
    File.open(@file).each_line do |line|
      array = line.split(' ')
      if array[8] == '404'
        unless results.has_key?("#{array[6]}")
          results.merge!("#{array[6]}" => 1)
        else
          results["#{array[6]}"] += 1
        end
      end
    end
    @top = Hash[results.sort_by { |k,v| -v }[0..99]]
    File.open("#{@cache_dir}/by_file/#{@date}", 'w') do |file|
      file.puts @top.to_yaml
    end
    @top
  end

  def by_site
    results = {}
    File.open(@file).each_line do |line|
      array = line.split(' ')
      if array[8] == '404'
        site = array[-3].split('=')[1]
        unless results.has_key?(site)
          results.merge!("#{site}" => 1)
        else
          results["#{site}"] += 1
        end
      end
    end
    @top = Hash[results.sort_by { |k,v| -v }[0..99]]
    File.open("#{@cache_dir}/by_site/#{@date}", 'w') do |file|
      file.puts @top.to_yaml
    end
    @top
  end

  def site_by_date(site)
    results = {}
    File.open(@file).each_line do |line|
      array = line.split(' ')
      if array[8] == '404'
        if array[-3].split('=')[1] == site
          unless results.has_key?("#{array[6]}")
            results.merge!("#{array[6]}" => 1)
          else
            results["#{array[6]}"] += 1
          end
        end
      end
    end
    @top = Hash[results.sort_by { |k,v| -v }[0..99]]
  end

  def referrer(site, file)
    results = {}
    File.open(@file).each_line do |line|
      array = line.split(' ')
      if array[8] == '404'
        if (array[-3].split('=')[1] == site && array[6] == file)
          unless results.has_key?("#{array[10]}")
            results.merge!("#{array[10]}" => 1)
          else
            results["#{array[10]}"] += 1
          end
        end
      end
    end
    @top = Hash[results.sort_by { |k,v| -v }[0..99]]
  end
end
