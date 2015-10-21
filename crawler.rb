#!/usr/bin/env ruby

# Public: Crawl a given uri and return a sitemap of per page relative uris and assets
#
# uri  - The URI to be crawled
# exclude - Optional ergular expression to exclude uris from crawl
#
# Examples
#
#   Crawler.new('https://www.digitalocean.com', '\/community\/|\/blog\/|\/assets\/|mailto')
#   # => 'TomTomTomTom'
#
# Returns the duplicated String.

gem 'nokogiri'
gem 'open_uri_redirections'

require 'nokogiri'
require 'open-uri'
require 'open_uri_redirections'

class Crawler

  attr_reader :base_uri, :relative_uris, :pages

  def initialize(uri, options = {exclude: '', allow_redirections: :none, output: false})
    puts options.inspect
    @base_uri = uri
    @relative_uris = []
    @pages = []
    @allow_redirections = options[:allow_redirections].to_sym
    @regex = '^\/\/|http|#' + options[:exclude]

    build_map_with(@base_uri)
    output_map if options[:output]
  end

  def output_map
    self.pages.map do |page|
      puts page[:uri]
      puts "links"
      page[:relative_uris].map {|link| puts "   #{link}"}
      puts "assets"
      page[:assets].map {|asset| puts "   #{asset}"}
    end
  end

  def build_map_with(uri)
    return if @relative_uris.include?(uri)
    doc = fetch_uri(uri)
    links = extract_local_uris(doc)
    assets = extract_assets(doc)
    @relative_uris << uri
    puts "indexed: #{uri}"
    @pages << {uri: uri, relative_uris: links, assets: assets}
    links.map{|link| build_map_with(@base_uri + link)}
  end

  def fetch_uri(uri)
    begin
      file = open(uri, :allow_redirections => @allow_redirections)
    rescue => e
      puts e
    end
    Nokogiri::HTML(file)
  end

  def extract_local_uris(doc)
    local_uris = []
    uris = extract_uris(doc)

    uris.map do |u|
      if u.value.match(/#{@regex}/).nil?
        local_uris << u.value.gsub(/^([^\/])/,'/\1')
      end
    end
    local_uris
  end

  def extract_uris(doc)
     doc.xpath('//a/@href')
  end

  def extract_assets(doc)
    doc.xpath('//img/@src|//link/@href|//script/@src').map{|asset| asset.value}
  end

end
