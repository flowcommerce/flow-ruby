require 'net/http'
require 'json'

class Parser

  WEIGHT = %w(pound pounds ounce ounces gram grams kilogram kilograms).map(&:downcase).uniq
  
  WOOD = %w(pine).map(&:downcase).uniq
  
  MATERIALS = %w(aluminum ceramic china copper cotton fabric glass iron leather metal paper plastic polyester porcelain rubber steel sugar wood).map(&:downcase).uniq
  
  INGREDIENTS = %w(coffee tea).map(&:downcase).uniq

  attr_reader :metadata
  
  def initialize(text)
    @metadata = {}

    text.split("\n").map(&:strip).each do |l|
      if md = l.match(/Made in:(.+)/i)
        @metadata[:origin] = fetch_country_of_origin(strip_html(md[1]))

      elsif md = l.match(/Made of:(.+)/i)
        text = strip_html(md[1])
        words = split(text)

        if matches?(words, WOOD)
          @metadata[:materials] = ["wood"]
        else
          @metadata[:materials] = intersect(words, MATERIALS)
        end

      elsif md = l.match(/size:(.+)/i)
        @metadata[:size] = strip_html(md[1])
      end

    end
  end

  
  def extract_numbers(value)
    puts value.split(/\s+/).map(&:strip).inspect
    value.split(/\s+/).map(&:strip).map { |v| is_number?(v) }.select { |v| !v.nil? }
  end

  def is_number?(value)
    Float(value)
  rescue
    nil
  end
  
  def split(value)
    value.split(/\s+/).map(&:strip).map(&:downcase).map { |v|
      v.gsub(/[^a-zA-Z0-9]/, '')
    }
  end

  def strip_html(text)
    text.gsub(/<\/?[^>]*>/, "").strip
  end

  def Parser.parse(text)
    Parser.new(text)
  end

  private
  def fetch_country_of_origin(text)
    url = URI('https://location.api.flow.io/locations?address=%s' % CGI.escape(text))
    result = Net::HTTP.get(url)
    if all = JSON.parse(result)
      if all.first
        if country = all.first['country']
          return country
        end
      end
    end
    nil
  rescue Exception => e
    puts "** Warning: Error fetting country of origin for[%s]: %s" % [text, e.to_s]
  end

  def matches?(values, words)
    (values & words).size > 0
  end
  
  def intersect(values, words)
    (values & words).uniq
  end
  
end
