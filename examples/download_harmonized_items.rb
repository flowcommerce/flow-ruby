require 'csv'
require 'json'

module DownloadHarmonizedItems
  
  def DownloadHarmonizedItems.run(harmonization_client, org)
    path = "/tmp/food52-harmonization.csv"
    CSV.open(path, "wb") do |csv|
      csv << ["number", "hs6", "country_of_origin", "materials", "keywords", "name", "made_in", "made_of", "size", "description"]
      
      #DownloadHarmonizedItems.run_internal(csv, harmonization_client, org, :limit => 100, :offset => 0, :number => ['2319-bowl_with_wood_wax'], :sort => 'number')
      DownloadHarmonizedItems.run_internal(csv, harmonization_client, org, :limit => 100, :offset => 0, :sort => 'number')
    end

    puts "Data downloaded to: %s" % path
  end

  def DownloadHarmonizedItems.run_internal(csv, harmonization_client, org, params)
    params[:limit] ||= 100
    params[:offset] ||= 0

    puts "Downloading items for org[%s] limit=%s offset=%s" % [org, params[:limit], params[:offset]]
    
    items = harmonization_client.harmonized_items.get(org, params)

    itemsNumbers = items.map { |i| i.number }

    hs6 = {}
    harmonization_client.hs6.get(org, :item_number => itemsNumbers).each do |rec|
      hs6[rec.item.number] = rec.code
    end
    
    items.each do |item|
      csv << [item.number,
              hs6[item.number],
              DownloadHarmonizedItems.extract(item.metadata, "origin"),
              DownloadHarmonizedItems.extract(item.metadata, "materials"),
              DownloadHarmonizedItems.extract(item.metadata, "keywords"),
              item.name,
              DownloadHarmonizedItems.extract(item.metadata, "made_in"),
              DownloadHarmonizedItems.extract(item.metadata, "made_of"),
              DownloadHarmonizedItems.extract(item.metadata, "size"),
              item.description
             ]
    end
    
    if items.size >= params[:limit]
      params[:offset] += params[:limit]
      DownloadHarmonizedItems.run_internal(csv, harmonization_client, org, params)
    end
  end

  def DownloadHarmonizedItems.extract(metadata, name)
    if value = metadata[name]
      if value == "null" || value == "\"\""
        nil
      elsif md = value.match(/^\"(.+)\"$/)
        md[1].to_s.strip
      else
        begin
          js = JSON.parse(value)
          if js.is_a?(Array)
            js.join(", ")
          else
            value.gsub(/\"/, '')
          end
        rescue
          puts "Error parsing[%s]" % value
          nil
        end
      end
    else
      nil
    end
  end
  
end
