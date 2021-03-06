#

require 'open-uri'
require 'nokogiri'
require 'date'
require 'json'

###
class WebDriver
  attr_accessor :page_data, :referer_url

  ###
  @@timeout = 600
  @@hash = nil
  @@referer_url = ""
  @@retry_flag = nil
  @@page_data = nil
  @@charset = nil

  ###
  def initialize(env_fname="env.json")
    @@hash = Hash.new
    if File.exist?(env_fname) then
      File.open(env_fname,"r") {|file|
        @@hash = JSON.load(file)
      }
    else
      @@hash["ua"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3770.142 Safari/537.36"
    end
    @@referer_url = ""
  end

  ### Set referer url
  def set_referer_url(url)
    @@referer_url = url
  end

  ### Get referer url
  def get_referer_url
    return @@referer_url
  end

  ### Get environment value
  def get_env_value(key)
    return @@hash[key]
  end

  ###
  def download(url, ref_url="", prefix="")
    status = self.get(url, ref_url)
    File.open("#{prefix}#{File.basename(url)}", "w") {|f|
      f.write(@@page_data)
    }
    return status
  end
  ###
  def get(url, ref_url="")
    status = nil
    ###
    @@referer_url = ref_url unless ref_url == ""
    charset = "utf-8"
    charset = @@hash["charset"] unless @@hash["charset"].nil?
    open(URI.escape(url), "r:#{charset}", "User-Agent"=>@@hash["ua"], "Referer"=>@@referer_url, :redirect => true) {|f|
      @@page_data = f.read
      status = f.status
    }
    return status
  end
  def page_source()
    return @@page_data
  end
  def get_parsed_content(url, ref_url="")
    get(url, ref_url)
    html = page_source
    return Nokogiri::HTML(html) unless html.nil?
    return nil                  if     html.nil?
  end
  def quit()
  end
end
