require 'rubygems'
require 'bundler/setup'

Bundler.require(:default)

require 'table-for'
require 'ostruct'
require 'xmlsimple'
require 'active_record'
require 'active_support/all'
require 'with_model'
require 'byebug'

def print_hash(hash)
  hash.inject("") { |s, (k, v)| "#{s} #{k}: #{v}." }
end

RSpec.configure do |config|
  config.extend WithModel
  config.mock_with :mocha
  ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
end

def normalize_html(html)
  html.gsub(/\s+/, "").gsub(/\"/, "'")
end

def html_includes?(html1, html2)
  normalize_html(html1).should include normalize_html(html2)
end
