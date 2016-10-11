module Hack

  def Hack.all_numbers(client, org, offset=0, results=[])
    puts "Fetching numbers offset[%s]" % offset
    limit = 100
    n = client.items.get(org, :limit => limit, :offset => offset).map(&:number)
    if n.size >= limit
      all_numbers(client, org, offset + limit, results.concat(n))
    else
      results.concat(n)
    end
  end

  def Hack.run(client, org)
    all = all_numbers(client, org)
    all.each_with_index do |n, i|
      if i % 50 == 0
        puts "Starting record %s/%s" % [i, all.size]
      end
      if n.match(/\:/)
        # client.items.delete_by_number(org, item.number)
        puts " - deleting %s" % n
      end
    end
  end

end
