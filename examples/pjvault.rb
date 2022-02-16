#!/usr/bin/env ruby

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'feedalizer'
require 'time'

# demo v2
url = 'https://blog.useproof.com'
feedalize(url) do
  rss_items = []

  feed.title = 'Proof Blog'
  feed.description = ''

  fd.scrape_items('//article') do |rss_item, html_element|
    link = html_element.xpath('a').last
    # next unless link
    # title = link.attributes.select {|attr| attr.name == 'aria-label'}.first.value

    rss_item.link  = link.get('href')
    rss_item.title = link.get('aria-label')

    description = html_element.xpath('p').first
    next if description.nil? || description.inner_text.nil?

    rss_item.description = description.inner_text
    rss_items << rss_item
  end

  # output!
  rss_items
end

# demo v1
feed = {}
num = 1
url = 'https://blog.useproof.com'
fd = Feedalizer::Feed.new(url)
fd.scrape_items('//article') do |rss_item, html_element|
  feed[num.to_s] = {
    rss_item: rss_item,
    html_element: html_element
  }

  num += 1
end
