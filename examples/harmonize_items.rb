require 'csv'
module HarmonizeItems
  
  def HarmonizeItems.load_explicit
    data = {}
    path = File.join(File.dirname(__FILE__), '../explicit-codes.csv')
    CSV.foreach(path, :headers => true, :header_converters => :symbol) do |row|
      number = row[:number].to_s.strip
      hs6 = [row[:item_hs_manual], row[:item_hs_returned]].map(&:to_s).map(&:strip).select { |i| !i.empty? }.first

      if !number.empty? && hs6
        data[number] = hs6
      end
    end
    data
  end

  def HarmonizeItems.run(catalog_client, harmonization_client, org)
    explicit = HarmonizeItems.load_explicit
    HarmonizeItems.run_internal(catalog_client, harmonization_client, explicit, org, 10, 0)
  end

  def HarmonizeItems.run_internal(catalog_client, harmonization_client, explicit, org, limit, offset)  
    #items = catalog_client.items.get(org, :limit => limit, :offset => offset, :number => ['480-Syrupandcream'])
    #items = catalog_client.items.get(org, :limit => limit, :offset => offset, :number => ['502-cherry'])
    items = catalog_client.items.get(org, :limit => limit, :offset => offset, :number => ['117-default_sku'])
    #items = catalog_client.items.get(org, :limit => limit, :offset => offset)
    
    items.each_with_index do |item, i|
      puts "%s. %s %s ..." % [offset+i+1, item.number, item.price.label]

      metadata = if item.description.to_s.strip.empty?
                   nil
                 else
                   Parser.new(item.description).metadata
                 end

      if explicit[item.number]
        metadata[:hs6] = explicit[item.number]
      end

      description = Parser.strip_html(item.description).to_s.gsub(/\s+/, ' ')

      puts " - categories: %s" % item.categories.join(", ")
      puts " - description: %s" % description
      puts " - metadata: %s" % metadata.inspect
      
      form = Io::Flow::Harmonization::V0::Models::HarmonizedItemPutForm.new(
        :name => item.name,
        :description => description,
        :categories => item.categories,
        :metadata => Hash[metadata.map { |k, v| [k, v.to_json.to_s] }]
      )

      harmonization_client.harmonized_items.put_by_number(org, item.number, form)
      puts ""
    end

    if items.size >= limit
      #HarmonizeItems.run_internal(catalog_client, harmonization_client, org, limit, offset + limit)
    end
  end

end
