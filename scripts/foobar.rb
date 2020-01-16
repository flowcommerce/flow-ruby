#!/usr/bin/env ruby

require 'flowcommerce'
require 'json'

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

def each_experience(client, org, limit=25, offset=0, &block)
  all = client.experiences.get(org, :limit => limit, :offset => offset)

  all.each do |exp|
    next if exp.status != ::Io::Flow::V0::Models::ExperienceStatus.active
    yield exp
  end

  if all.size >= limit
    each_experience(client, org, limit, offset + limit, &block)
  end
end

def each_local_item(client, org, key, limit=25, offset=0, &block)
  all = client.experiences.get_local_and_items_by_experience_key(org, key, :limit => limit, :offset => offset)

  all.each do |loc|
    yield loc
  end

  if all.size >= limit
    each_local_item(client, org, key, limit, offset + limit, &block)
  end
end

# iterate through all the experiences
each_experience(client, org) do |exp|
  # val bytes = Seq(Some(org), Some(experienceId), Some(itemNumber), centerKey).flatten.mkString(":").getBytes()
  puts "ORG[#{org}] EXPERIENCE[#{exp.key}]"

  each_local_item(client, org, exp.key) do |local_item|
    x = [org, exp.id, local_item.item.number].join(":")
    id = `scala Foo '#{x}'`
    puts id # erm_item.local_items.id
    hash = JSON.parse(local_item.to_json)
    pricing_attributes = hash["pricing"]["attributes"].to_json
    item_id = local_item.item.id
    item_number = local_item.item.number
    experience_id = local_item.experience.id
    experience_key = local_item.experience.key
    experience_language = local_item.experience.language
    experience_name = local_item.experience.name
    experience_country = local_item.experience.country
    experience_currency = local_item.experience.currency

    pricing_price_amount = local_item.pricing.price.amount
    pricing_price_currency = local_item.pricing.price.currency
    pricing_price_label = local_item.pricing.price.label

    pricing_price_base_amount = local_item.pricing.price.base.amount
    pricing_price_base_currency = local_item.pricing.price.base.currency
    pricing_price_base_label = local_item.pricing.price.base.label


    pricing_price_amount                            │ 475.0
    pricing_price_base_amount                       │ 345.0
    pricing_price_base_currency                     │ USD
    pricing_price_base_label                        │ US$345.00
    pricing_price_currency                          │ CAD
    pricing_price_includes_key                      │ vat_and_duty
    pricing_price_includes_label                    │ Includes HST and duty
    pricing_price_label                             │ CA$475.00








    puts pricing_attributes
    puts "-----------------"
  end
  puts "============================================================="
end

=begin
{
  "id":"cit-7c933e0f52f5495e8c6e584f7faad45f",
  "experience":{
    "id":"exp-a6ca8bfe711b4b32859864462a0a2fbf",
    "key":"new-zealand",
    "name":"New Zealand",
    "country":null,
    "currency":null,
    "language":null
  },
  "center":null,
  "item":{
    "id":"cit-7c933e0f52f5495e8c6e584f7faad45f",
    "number":"joyride"
  },
  "pricing":{
    "price":{
      "currency":"NZD",
      "amount":196,
      "label":"NZ$196.00",
      "base":{
        "amount":124.91,
        "currency":"USD",
        "label":"US$124.91"
      },
      "includes":{
        "key":"vat",
        "label":"Includes GST"
      },
      "key":"localized_item_price"
    },
    "vat":null,
    "duty":null,
    "attributes":{
      "mvmt-sale-prices":{
        "currency":"NZD",
        "amount":196,
        "label":"NZ$196.00",
        "base":{
          "amount":124.91,
          "currency":"USD",
          "label":"US$124.91"
        }
      },
      "mvmt-list-prices":{
        "currency":"NZD",
        "amount":220,
        "label":"NZ$220.00",
        "base":{
          "amount":140.21,
          "currency":"USD",
          "label":"US$140.21"
        }
      }
    }
  },
  "status":"included"
}
=end

=begin
select * from erm_item.local_items where organization_id ='mzwallace' and item_number='22685' and experience_key='canada';
    id                                              │ lit-136049c89c9f3a60b58d8d421046c075
    organization_id                                 │ mzwallace
    experience_country                              │ CAN
    experience_currency                             │ CAD
    experience_id                                   │ exp-35fce9942c884dd1956534c08122d633
    experience_key                                  │ canada
    experience_language                             │ en
    experience_name                                 │ Canada
    item_id                                         │ cit-e9747bf9e6ad47ea9baba88e5c9ea262
    item_number                                     │ 22685
    pricing_attributes                              │ {"usd-msrp":{"amount":595,"currency":"CAD","label":"CA$595.00","base":{"amount":439.44,"currency":"USD","label":"US$439.44"}}}
    pricing_price_amount                            │ 475.0
    pricing_price_base_amount                       │ 345.0
    pricing_price_base_currency                     │ USD
    pricing_price_base_label                        │ US$345.00
    pricing_price_currency                          │ CAD
    pricing_price_includes_key                      │ vat_and_duty
    pricing_price_includes_label                    │ Includes HST and duty
    pricing_price_label                             │ CA$475.00
    status                                          │ included
    _hash_code                                      │ -86733699
    _updated_at                                     │ 2020-01-16 05:39:36.404+00
    _version                                        │ 1
=end
