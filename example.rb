#!/usr/bin/env ruby

require 'flowcommerce'

# Enable for local testing
# load 'lib/flowcommerce.rb'

load 'examples/util.rb'

puts ""
puts "Welcome to Flow Commerce"
puts "---------------------------------------------------------------------------------"
puts "We hope these examples are helpful! We're always open to suggestions and comments"
puts "Pls feel free to:"
puts "  - open PRs or log issues in github https://github.com/flowcommerce/ruby-sdk"
puts "  - email us at tech@flow.io"
puts ""
puts "Thanks and enjoy!"
puts ""

clients = begin
            FlowCommerce.instance
         rescue Exception => e
           puts ""
           puts "*** ERROR No API Token Found ***"
           puts e.to_s
           puts ""
           puts "  To use the examples, you must provide your Flow API Token in one of the following ways:"
           puts "    1. create a file at %s containing your token" % FlowCommerce::DEFAULT_TOKEN_FILE_LOCATION
           puts "    2. pass your token in via env var: FLOW_TOKEN=xxx ./example.rb"
           puts "    3. place your token in a file and pass in the location: FLOW_TOKEN_FILE=/xxx/yyy/token.txt ./example.rb"
           puts ""
           exit(1)
         end

org = ARGV.shift.to_s.strip
if org == ""
  org = Util::Ask.for_string("Pls enter your organization ID (note you can also pass in directly to this script): ")
end

Util.display_menu
selection = nil
while selection.nil?
  value = Util::Ask.for_positive_integer("Select example to run:")
  selection = Util::MENU[value - 1]
end

puts ""
puts "Running example: %s" % selection.title
puts ""

selection.run(clients, org)

exit(1)

items = client.subcatalog_items.get(org, "canada", :limit => 10, :offset => 0)

items.each_with_index do |item, i|
  puts item.inspect
  puts "  %s. item %s: %s %s" % [i, item.number, item.price.amount, item.currency]
end


puts ""
puts "Searching by specific item number"

items = client.subcatalog_items.get(org, "canada", :number => ['R030G-8', 'R028CL-7'])

items.each_with_index do |item, i|
  puts item.inspect
  puts "  %s. item %s: %s %s" % [i, item.number, item.price.amount, item.currency]
end
