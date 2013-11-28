#!/usr/bin/env ruby

require 'rubygems'
require 'json'
require 'net/http'
require 'uri'
require 'pp'
require 'erb'
require 'pry'


class Wikipage
  attr_accessor :error
  include ERB::Util

  def initialize(options = {})
    unless options["error"]
      @vars = {}
      @error = false
      options["facts"].each do |key,value|
        @vars[key] = value
      end
      @name = options["name"]
      @template = options[:template]
      @overwrite = options[:overwrite]
    else
      @error = options["error"]
    end
  end

  def render(template = @template)
    ERB.new(File.read(template), nil, '-').result(binding)
  end

  def save(file)
    unless File.exist?(file) and @overwrite == false
      File.open(file, "w") do |f|
        f.write(render)
      end
    else
      puts "Refusing to write #{file}"
    end
  end

  def show
    puts render
  end

  def lookupvar(var)
    return @vars[var]
  end

  def scope
    self
  end

  def function_template(file)
    file.each do |x|
      return render(x)
    end
  end

  def method_missing (method_name)
    if @vars[method_name.to_s]
      return @vars[method_name.to_s]
    else
      puts "#{method_name} not implemented"
      raise NoMethodError
    end
  end

  def to_hash
    @vars
  end
end

def ask_db(path)
  puppetdb = "http://puppetdb.example.com:8080"
  
  uri = URI.parse("#{puppetdb}/v1/#{path}")
  http = Net::HTTP.new(uri.host, uri.port)
  request = Net::HTTP::Get.new(uri.request_uri)
  params = { :query => '["=", ["node", "active"], true]' }
  request.set_form_data(params)
  request.initialize_http_header({"Accept" => "application/json"})
  response = http.request(request)
  return JSON.parse(response.body)
end


nodelist = ask_db("nodes")
#nodelist = [ "avl2101p.it.internal" ]

@docpath = "/appl/webapps/hostdocumentation/data/gitrepo/pages/server"
@factpath = "/appl/webapps/hostdocumentation/data/gitrepo/pages/facts"

nodelist.each do |node|
  facts = ask_db("facts/#{node}")
  docpage = Wikipage.new(facts.merge({ :template => 'template/host.txt.erb', :overwrite => false}) )
  factpage = Wikipage.new(facts.merge({ :template => 'template/facts.txt.erb', :overwrite => true}) )

  unless factpage.error
    factpage.save("#{@factpath}/#{factpage.hostname}.txt") 
    docpage.save("#{@docpath}/#{factpage.hostname}.txt")
  else
    puts factpage.error
  end
end
