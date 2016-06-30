module HarmonizeItems

  def HarmonizeItems.run(catalog_client, harmonization_client, org)
    HarmonizeItems.run_internal(catalog_client, harmonization_client, org, 100, 0)
  end

  def HarmonizeItems.run_internal(catalog_client, harmonization_client, org, limit, offset)  
    items = catalog_client.items.get(org, :limit => limit, :offset => offset)
    items.each_with_index do |item, i|
      print "%s. %s %s ..." % [offset+i+1, item.number, item.price.label]
      harmonization_client.harmonized_items.put_by_number(org, item.number,
                                                          Io::Flow::Harmonization::V0::Models::HarmonizedItemPutForm.new(
                                                            :description => item.description,
                                                            :categories => item.categories
                                                          ))
      puts ""
    end

    if items.size >= limit
      HarmonizeItems.run_internal(catalog_client, harmonization_client, org, limit, offset + limit)
    end
  end

end
