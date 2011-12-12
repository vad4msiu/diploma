# -*- encoding : utf-8 -*-
require 'nokogiri'
require 'open-uri'
require "cgi"
require "iconv"

module ScrapingYandex
  def self.search(options = {})
    raise ArgumentError, "Query is not a Hash" unless options.is_a? Hash
    raise ArgumentError, "Is not empty query" unless options[:query]
    ic = Iconv.new('UTF-8//IGNORE', 'UTF-8')
    documents = {}
    issuance = Nokogiri::HTML(open("http://yandex.ru/yandsearch?text=#{CGI::escape(options[:query])}").read)
    issuance.css('a.b-serp-item__title-link').each do |link|
      begin
        href = link.attributes["href"].content
        html = open(href)
        if html.content_type == "text/html"
          doc = Nokogiri::HTML(html.read)
          doc.css('script').remove
          doc.css('style').remove
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
