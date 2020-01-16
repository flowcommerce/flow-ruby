#!/usr/bin/env ruby

require 'flowcommerce'

org = ARGV.shift.to_s.strip

if org.empty?
  puts "usage: migrate-logistics.rb <organization id>"
  exit(1)
end

# Assume API keys are located in ~/.flow/<org id>
def client(org)
  path = File.expand_path("~/.flow/%s" % org)
  if !File.exists?(path)
    puts "Error: Token for org %s not in path %s" % [org, path]
    exit(1)
  end
  FlowCommerce.instance(:token => IO.read(path).strip)
end

# get a client for the organziation
client = client(org)

def each_experience(client, org, limit=200, offset=0, &block)
  all = client.experiences.get(org, :limit => limit, :offset => offset)

  all.each do |exp|
    next if exp.status != ::Io::Flow::V0::Models::ExperienceStatus.active
    yield exp
  end

  if all.size >= limit
    each_experience(client, org, limit, offset + limit, &block)
  end
end

items = client.items.get(org, :limit => 200, :offset => 0)

# iterate through all the experiences
each_experience(client, org) do |exp|
  puts "ORG[#{org}] EXPERIENCE[#{exp.key}]"
  items.each do |item|
    puts item.number
  end
  puts "=========" * 12
end
