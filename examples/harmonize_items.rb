module HarmonizeItems

  def HarmonizeItems.run(catalog_client, harmonization_client, org)
    HarmonizeItems.run_internal(catalog_client, harmonization_client, org, 25, 0)
  end

  def HarmonizeItems.run_internal(catalog_client, harmonization_client, org, limit, offset)  
    #items = catalog_client.items.get(org, :limit => limit, :offset => offset, :number => ['480-Syrupandcream'])
    #items = catalog_client.items.get(org, :limit => limit, :offset => offset, :number => ['502-cherry'])
    items = catalog_client.items.get(org, :limit => limit, :offset => offset)
    
    items.each_with_index do |item, i|
      puts "%s. %s %s ..." % [offset+i+1, item.number, item.price.label]

      metadata = if item.description.to_s.strip.empty?
                   nil
                 else
                   Parser.new(item.description).metadata
                 end

      puts " - categories: %s" % item.categories.join(", ")
      puts " - metadata: %s" % metadata.inspect

      description = (item.name + item.description).strip
      harmonization_client.harmonized_items.put_by_number(org, item.number,
                                                          Io::Flow::Harmonization::V0::Models::HarmonizedItemPutForm.new(
                                                            :name => item.name,
                                                            :description => description,
                                                            :categories => item.categories,
                                                            :metadata => @metadata
                                                          ))
      puts ""
    end

    if items.size >= limit
      #HarmonizeItems.run_internal(catalog_client, harmonization_client, org, limit, offset + limit)
    end
  end

end
