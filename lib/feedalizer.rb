require 'feedalizer/version'
require 'rss/maker'
require 'open-uri'
require 'oga'

module Feedalizer
  class Feed
    IDENTIFIER = "Feedalizer/#{Feedalizer::VERSION} (https://github.com/michaelrigart/feedalizer)"

    attr_reader :page

    def initialize(url, &block)
      @page = grab_page(url)
      @rss = RSS::Maker::RSS20.new

      feed.generator = IDENTIFIER
      feed.link = url
      feed.description = "Scraped from #{url}"

      instance_eval(&block) if block
    end

    def feed
      @rss.channel
    end

    def scrape_items(query, limit = 15)
      elements = @page.xpath(query)

      elements.first(limit).each do |html_element|
        rss_item = @rss.items.new_item
        yield rss_item, html_element
      end
    end

    def grab_page(url)
      URI.open(url) { |io| Oga.parse_html(io) }
    end

    def output
      @rss.to_feed.to_s
    end

    def output!(target = STDOUT)
      target << output
    end

    def debug!
      @rss.items.each do |item|
        STDERR.puts [item.title, item.date, item.link].join('; ')
      end
    end
  end
end
# A handy wrapper for Feedalizer.new :-)
def feedalize(*args, &block)
  Feedalizer::Feed.new(*args, &block)
end
