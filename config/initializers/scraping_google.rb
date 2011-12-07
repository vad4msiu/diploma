# -*- encoding : utf-8 -*-
require 'nokogiri'
require 'open-uri'
require "cgi"

module ScrapingGoogle
  def self.search(options = {})
    raise ArgumentError, "Query is not a Hash" unless options.is_a? Hash
    query = options[:query]
    raise ArgumentError, "Is not empty query" unless query
    Rails.logger.debug { "query: #{query}" }
    ic = Iconv.new('UTF-8//IGNORE', 'UTF-8')
    documents = {}
    issuance = Nokogiri::HTML(open("http://www.google.com/search?q=#{CGI::escape(query)}").read)
    issuance.css('h3.r a').each do |link|
      begin
        href = link.attributes["href"].content
        html = open(href)
        if html.content_type == "text/html"
          doc = Nokogiri::HTML(html.read)
          doc.css('script').remove
          content = ic.iconv(doc.content)
          documents.merge! href => content
        end
      rescue Exception => e
        Rails.logger.debug { "#{e}" }
        next
      end
    end

    return documents
  end
end
