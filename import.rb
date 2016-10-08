#!/usr/bin/env ruby

load 'lib/flowcommerce.rb'
load 'examples/util.rb'

client = begin
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

orgs = client.organizations.get(:sort => 'id')

if orgs.empty?
  puts "*** ERROR: Your account is not associated with any organizations"
  puts "***        Please visit https://console.flow.io to create an organization"
  exit(1)

else
  if org = ARGV.shift
    if orgs.find { |o| o.id == org }.nil?
      puts "** ERROR ** Invalid org[%s]. Must be one of: %s" % [org, orgs.map { |o| o.id }]
      exit(1)
    end

  else
    puts ""
    puts "You are a member of:"
    orgs.each do |org|
      puts " - %s: environment[%s]" % [org.id, org.environment.value]
    end
    while orgs.find { |o| o.id == org }.nil?
      org = Util::Ask.for_string("Pls enter your organization Id (note you can also pass in directly to this script): ")
    end
  end
end

if path = ARGV.shift
  if !File.exists?(path)
    puts "** WARNING ** File %s not found" % path
    path = nil
  end
end

while path.nil?
  path = Util::Ask.for_string("Enter path to file to upload: ")
  if !File.exists?(path)
    puts "** ERROR ** File not found"
    path = nil
  end
end

name = File.basename(path)
api_key = FlowCommerce.token
cmd = "curl --silent --data-binary @#{path} -H 'Content-type: text/plain' -u #{api_key}: 'https://api.flow.io/#{org}/uploads/#{name}'"
puts cmd
upload = JSON.parse(`#{cmd}`.strip)
puts "Uploaded file to %s" % upload['url']

imp = client.imports.post(org,
                          ::Io::Flow::V0::Models::ImportForm.new(
                            :type => ::Io::Flow::V0::Models::ImportType.harmonization_codes,
                            :source_url => upload['url'],
                            :emails => ['mike@flow.io']
                          )
                         )

puts "Created import: #{imp.id}"



