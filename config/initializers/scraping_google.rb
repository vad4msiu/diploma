require 'nokogiri'
require 'open-uri'
require "cgi"

module ScrapingGoogle
  def self.search(options = {})
    raise ArgumentError, "Query is not a Hash" unless options.is_a? Hash
    query = options[:query]
    raise ArgumentError, "Is not empty query" unless query
    documents = {}
    doc = Nokogiri::HTML(open("http://www.google.com/search?q=#{CGI::escape(query)}"))
    first = false
    doc.css('h3.r a').each do |link|
      unless first
        begin
          href = link.attributes["href"].content
          documents.merge! href => Nokogiri::HTML(open(href)).content
        rescue Exception => e
          Rails.logger.debug { "#{e}" }
          next
        end
      end
      first = true
    end

    return documents
  end
end