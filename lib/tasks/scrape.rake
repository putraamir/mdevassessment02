require "nokogiri"
require "httparty"

namespace :scrape do
  desc "Scrape headlines from The Verge"
  task headlines: :environment do
    url = "https://www.theverge.com/"
    response = HTTParty.get(url)
    doc = Nokogiri::HTML(response.body)

    doc.css("*.duet--content-cards--content-card").each do |link|
      title = link.css("h2 a").text.strip

      href = link.css("h2 a").attr("href")&.value
      url = "https://www.theverge.com#{href}"

      date_str = link.css("time").text.strip
      published_at = get_article_date(url) || parse_date(date_str)

      @article = Article.find_or_create_by(
        title: title,
        url: url,
        published_at: published_at
      )
    end
  end
end

def parse_date(date_str)
  return DateTime.current if date_str.blank?

  current_time = DateTime.current

  case date_str.downcase
  when /(\d+)\s+hours?\s+ago/
    current_time - $1.to_i.hours
  when /(\d+)\s+minutes?\s+ago/
    current_time - $1.to_i.minutes
  when "an hour ago"
    current_time - 1.hour
  when "two hours ago"
    current_time - 2.hours
  when /(\w+)\s+(\d+)/
    Date.parse(date_str).to_datetime.change(year: current_time.year)
  else
    begin
      DateTime.parse(date_str)
    rescue ArgumentError
      puts "Failed to parse date: #{date_str}"
      current_time
    end
  end
rescue => e
  puts "Error parsing date '#{date_str}': #{e.message}"
  current_time
end

def get_article_date(article_url)
  response = HTTParty.get(article_url)
  article_doc = Nokogiri::HTML(response.body)

  # Look for time tag with datetime attribute in article
  time_element = article_doc.at("*.duet--article--timestamp")
  return DateTime.parse(time_element["datetime"]) if time_element && time_element["datetime"]

  # Fallback to meta tag if time element not found
  meta_time = article_doc.at('meta[property="article:published_time"]')&.[]("content")
  return DateTime.parse(meta_time) if meta_time.present?

  nil
rescue => e
  puts "Error fetching article date from #{article_url}: #{e.message}"
  nil
end
