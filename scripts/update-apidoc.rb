#!/usr/bin/env ruby

# Grabs the current version of the API, downloads the latest and if
# there is a difference commits the new version. Used by our release
# script to document in the git commit exactly what the version change
# in the API was.
#
# Example:
#  ./update-apidoc.rb
#

dir = File.dirname(__FILE__)

def extract_version(path)
  IO.readlines(path).each do |l|
    #if md = l.strip.match(/VERSION\s*=\s*[\'\"]?([^\'\"]+)/i)
    if md = l.strip.match(/apidoc.+http\:\/\/.+\/flow\/api\/([\d\.]+)/i)
      return md[1]
    end
  end

  puts "ERROR: Could not extract current version"
  exit(1)
end

path = File.join(dir, "../lib/flow_commerce/flow_api_v0_client.rb")
current = extract_version(path)
system("cd %s && apidoc update" % File.join(dir, ".."))
latest = extract_version(path)

if current == latest
  puts "apidoc API version remains at %s" % current
  puts ""
  exit(1)
end

msg = "Update API version from %s to %s" % [current, latest]
msg << ""
msg << "  - See http://apidoc.me/history?org=flow&app=api&from=%s&to=%s" % [current, latest]

system("git commit -m '%s' lib/flow_commerce/flow*rb" % msg)

