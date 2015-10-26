## !/usr/bin/env ruby

require_relative 'test_helper'
require_relative 'crawler'

describe Crawler, :vcr do
  def self.crawler
    @crawler ||= Crawler.new('https://www.digitalocean.com', { exclude: '|\/community\/|\/blog\/|\/assets\/|mailto', allow_redirections: :all })
  end

  it 'responds with accurate URI count' do
    self.class.crawler.relative_uris.count.must_equal 100
  end

  it 'responds with accurate page count' do
    self.class.crawler.pages.count.must_equal 100
  end

  it 'has uri value' do
    self.class.crawler.pages.first[:uri].must_equal 'https://www.digitalocean.com'
  end

  it 'has list of relative_uris' do
    self.class.crawler.pages.first[:relative_uris].count.must_equal 24
  end

  it 'has list of assets' do
    self.class.crawler.pages.first[:assets].count.must_equal 19
  end
end
