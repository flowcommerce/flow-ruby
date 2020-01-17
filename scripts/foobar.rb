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

=begin
experience_ids = {
  "new-zealand" => "exp-20c211b8be1e4d0c9b64d70efb967ab2",
  "mexico" => "exp-1cc2495d95dc434d85716208a6f3bbcd",
  "china" => "exp-750a5a50aad045429e1b27cb04827adb",
  "canada" => "exp-ac61ab7783f9491a9742abbbfd271c13",
  "australia" => "exp-8d8cc3523cd741368950fb2f5695102a"
}
=end

all_items = [13274, 15918, 19414, 19489, 19511, 20144, 20958, 22768, 22769, 22782, 22877, 22880, 24264, 24881, 24882, 24883, 25083, 25586, 25587, 25588, 25589, 25590, 25591, 25592, 25593, 25594, 25595, 25596, 25597, 25598, 25599, 25600, 25601, 25602, 25603, 25604, 25605, 25606, 25607, 25608, 25609, 25610, 25611, 25612, 25613, 25614, 25615, 25616, 25617, 25618, 25619, 25620, 25621, 25622, 25623, 25624, 25625, 25626, 25627, 25628, 25629, 25630, 25631, 25632, 25633, 25634, 25635, 25636, 25637, 25638, 25639, 25641, 25642, 25644, 25645, 25646, 25647, 25648, 25651, 25652, 25653, 25654, 25655, 25656, 25657, 25658, 25659, 25660, 25661, 25662, 25663, 25664, 25665, 25666, 25667, 25668, 25669, 25671, 25672, 25673, 25674, 25675, 25676, 25678, 25679, 25680, 25681, 25682, 25683, 25684, 25685, 25686, 25687, 25688, 25689, 25690, 25691, 25692, 25693, 25694, 25695, 25696, 25697, 25698, 25699, 25700, 25701, 25702, 25703, 25704, 25705, 25706, 25707, 25708, 25786, 25787, 25788, 25790, 25791, 25792, 25793, 25794, 25795, 25796, 25797, 25798, 25800, 25801, 25802, 25803, 25804, 25805, 25807, 25808, 25809, 25810, 25887, 25986]

experience_ids = {
  "american-samoa" => "exp-d65c5f4020ec42c99fb94f166ba2411d",
  "andorra" => "exp-7e9c043adaa4440aad5930398258e80e",
  "anguilla" => "exp-88b5a9cd6fde406ba478db858abab663",
  "antigua-and-barbuda" => "exp-5abd802279ea45f78a3ce52e378e298e",
  "argentina" => "exp-f95c3687871342fd9e2404fd872919bc",
  "armenia" => "exp-350e388ce4da4eda906dd0f6b6e89686",
  "aruba" => "exp-49e204f7bd544fe0b40886049849866d",
  "australia" => "exp-eb54c9ed07c64856aeb58b4f91b84576",
  "australia-google-pay-variant" => "exp-c4df87355b0346faabb0c7bd2bf142bf",
  "austria" => "exp-5539414b28c54ac39ff8fd827c4b454c",
  "bahamas" => "exp-521dc5b3f7904f8a840632fe3f240345",
  "bahrain" => "exp-7e477f538a1f491caf61ac87c26b5263",
  "bangladesh" => "exp-e3478e3b9b3e4e038d54240daae45941",
  "belgium" => "exp-e5aa31a6230947f4916415b1e8ee7c5b",
  "belize" => "exp-47ce49a008ae422aa8b4bdd8e4ef6b7c",
  "bolivia" => "exp-a34608ec541143c2a881ce44ea3826ff",
  "brazil" => "exp-88ec4db0f2394248b2eca82646552418",
  "brunei-darussalam" => "exp-26bd9a63ab3b4a70a81faf2305884af6",
  "bulgaria" => "exp-306b45a642f34b6c9eb83d79f5a5a1b9",
  "canada" => "exp-35fce9942c884dd1956534c08122d633",
  "chile" => "exp-87129acb6d6f4de484e121313b062465",
  "china" => "exp-6520636b3ee54c639219eccfe609d2f5",
  "colombia" => "exp-05bedb7b9d05441fa67c82fe96545d75",
  "costa-rica" => "exp-9c67f17ccb284ddc9ed0114e7bbacd8c",
  "croatia" => "exp-821442e28b444da29d34bedfe60d3a1b",
  "cura-ao" => "exp-bf75a1624eec4501bc1bd24915835e2a",
  "cyprus" => "exp-1c1188bb2dd44933bb238d855924327c",
  "czechia" => "exp-f659d722debf48a79973c638bcab06a3",
  "denmark" => "exp-58c29f5c3d804b5693da2dd53a8ca2b1",
  "dominica" => "exp-df47b229412c4063af46f48deff91fdc",
  "dominican-republic" => "exp-cd424bdefbe14b1bb4724cd4e3f11952",
  "ecuador" => "exp-d0218b8b80cd47ef8a79e080b3bc72e0",
  "egypt" => "exp-9a423caee4204d4bb1ad149357d88985",
  "el-salvador" => "exp-4c1b9d3a804d44dc8a6550b130cf22a5",
  "equatorial-guinea" => "exp-5cdcae4f95864e4cabac64d809bae41d",
  "estonia" => "exp-3b2f8957a2e543408fac760cd67c1cd4",
  "finland" => "exp-9b1105ab381e4e958a489023b0347962",
  "france" => "exp-c76514e51bc24a1fae0d47ce38214542",
  "germany" => "exp-24555d04f1264f7a831930da915e33b6",
  "greece" => "exp-52f590dbc1bd41b291dc76f256b689c7",
  "grenada" => "exp-bf00b99d025e4e85bf5f158cef75db30",
  "guatemala" => "exp-a14eae735e7142939c2d879e9428e394",
  "haiti" => "exp-49449234aa14460da34ef64c6d616c64",
  "honduras" => "exp-f9ee254106fc436e8164bef48237a8f2",
  "hong-kong" => "exp-d47eec74cdda42c4b80963b130db9169",
  "hungary" => "exp-80b250ba61d24021b55d6d84b9d1e7cc",
  "iceland" => "exp-a8a2a670f23142dbb2f9948af7aee53f",
  "ireland" => "exp-a942d30653b0452f8590ae86ac1a444b",
  "israel" => "exp-481e008c7d44414eb9bd263af6cc7300",
  "italy" => "exp-425f201cd9f147efa0bbd3fa039d231d",
  "jamaica" => "exp-03924941a1004d488ae6dd08460f3d96",
  "japan" => "exp-c3f6447e44f643528c1a1ec612a3b577",
  "jordan" => "exp-74e95e072eae4c20b5cad775b61b3916",
  "kuwait" => "exp-360d649e815c4397b30eae2ca5d61222",
  "latvia" => "exp-a1f9244c1e9243d795b232bc27319015",
  "lebanon" => "exp-bb41c669953b4f489e1cc8fe1c95f5c2",
  "liechtenstein" => "exp-88983700d2f948ee9f01e3a083bf531e",
  "lithuania" => "exp-75b19584ad08462e817a25ac74c6ee07",
  "luxembourg" => "exp-9e4dd9a182a24107ae9aaba0ed81dd2d",
  "macau" => "exp-0de1744efab84a1ea15d631723f926e1",
  "malaysia" => "exp-78e11c8f9018467c809e1934a4297078",
  "malta" => "exp-a05d2a3cb7b542dd8976aea0a3f5b70d",
  "mexico" => "exp-8d3b62139ba8416ba1d56311dc6db14c",
  "monaco" => "exp-c8b4f2aed1d847cc9803ff32b5c4226d",
  "netherlands" => "exp-e6222179bc0449ee87cb9e74ed16074b",
  "new-zealand" => "exp-9bc31cbc74594355807c6d3d11c3c97d",
  "nicaragua" => "exp-b73c593aba9f4a29a049bc00fa5b19a8",
  "norway" => "exp-fbaae24e4f094b49af6934a1d3a97016",
  "oman" => "exp-b28ad16c54624448a70573c00cc50dd9",
  "pakistan" => "exp-73f478a17553460c9cec88754554461d",
  "panama" => "exp-f105908a8d4a43bd89b54ad335eb6bb1",
  "paraguay" => "exp-cfaf0cb98fb54fe7a2cff3f11f63cb14",
  "peru" => "exp-07ea55b1004049e8bdcdf9fea2b41f02",
  "philippines" => "exp-459a165673f14a7cabc74d4e8aee0415",
  "poland" => "exp-8351e4bb64a749179daeb1f1e6a5aeca",
  "portugal" => "exp-7c4e85dab3a049328ab5bbed51a82fcd",
  "qatar" => "exp-5ebe50240f9544a791794a6c076b63ac",
  "republic-of-korea" => "exp-d418b47f820c4ab1892493da8ebd46aa",
  "romania" => "exp-69361afcae6a4fa89f30f94847211d2d",
  "saint-kitts-and-nevis" => "exp-ee4981ce97d04cce8468a66b1dda2949",
  "saint-lucia" => "exp-e7352d676c6a4b3f8c08338ce29f47b4",
  "saint-martin" => "exp-41dc560d3de540319fdc8cdfd5fbcfe6",
  "saint-vincent-and-the-grenadines" => "exp-749a8004e90b4f05aeceb9a56430935c",
  "san-marino" => "exp-31080e2ad208448f976836b782c4b34e",
  "saudi-arabia" => "exp-5a7407a21dcd483ba412a30d746cbae3",
  "singapore" => "exp-a485c28e490f43c7906dc6ea9d9ed738",
  "slovakia" => "exp-8558a0338b7a46ca9bda69562fcddf7e",
  "slovenia" => "exp-16b37ed9716a40609622d11d345bdc23",
  "somalia" => "exp-7c1c555f2efa44fc8a5b39a8c6aa6c8d",
  "spain" => "exp-870316a5fa724823838d7c2525249dce",
  "sri-lanka" => "exp-bb99a0078874436c9e32d2c0e6a351c9",
  "sweden" => "exp-654f2773a9d44f84b8a64cba8c729e09",
  "switzerland" => "exp-433b95d4811b4fca9ea93573629729ee",
  "taiwan" => "exp-6050090b7ec14f289fadf573b8ec4480",
  "thailand" => "exp-22729d927daa43ceb536c29f5a34b8b7",
  "timor-leste" => "exp-769c977bf8734608b386cf3736cf59ef",
  "trinidad-and-tobago" => "exp-1d8d2e3e49ca42879d242495e7619f70",
  "united-arab-emirates" => "exp-cb7795da24304cc4bbb1cf85da2c1a71",
  "united-kingdom" => "exp-1b8e6aca662b427888fc222491444cb9",
  "united-states-of-america" => "exp-4ec23b07a4c34996bf73432a156d6b99",
  "uruguay" => "exp-488c947fefaf42d897e1f85e0bdfb470",
  "viet-nam" => "exp-3e8067d610b546fea22668b706e29eea",
}


# iterate through all the experiences
each_experience(client, org) do |exp|
  # val bytes = Seq(Some(org), Some(experienceId), Some(itemNumber), centerKey).flatten.mkString(":").getBytes()
  puts "ORG[#{org}] EXPERIENCE[#{exp.key}]"

  metric_experience_id = experience_ids[exp.key]

  all_items.each do |item|
    local_item = client.experiences.get_local_and_items_by_experience_key(org, exp.key, :q => "number in (#{item})", :limit => 1, :offset => 0).first
    x = [org, metric_experience_id, local_item.item.number].join(":")
    hash = JSON.parse(local_item.to_json)

    # ==================================================
    # ==================================================
    # ==================================================
    id = `scala Foo '#{x}'`.strip
    organization_id = org
    experience_country = exp.country
    experience_currency = exp.currency
    experience_id = metric_experience_id
    experience_key = local_item.experience.key
    experience_language = exp.language
    experience_name = local_item.experience.name
    item_id = local_item.item.id
    item_number = local_item.item.number
    pricing_attributes = hash["pricing"]["attributes"].to_json
    pricing_price_amount = local_item.pricing.price.amount
    pricing_price_base_amount = local_item.pricing.price.base.amount
    pricing_price_base_currency = local_item.pricing.price.base.currency
    pricing_price_base_label = local_item.pricing.price.base.label
    pricing_price_currency = local_item.pricing.price.currency
    pricing_price_includes_key = local_item.pricing.price.includes.key.value
    pricing_price_includes_label = local_item.pricing.price.includes.label
    pricing_price_label = local_item.pricing.price.label
    status = local_item.status.value
    _hash_code = 9898989
    _version = 1
    _updated_at = "now()"
    # ==================================================
    # ==================================================
    # ==================================================
    sql = <<-"EOF"
insert into erm_item.local_items (
  id,
  organization_id,
  experience_country,
  experience_currency,
  experience_id,
  experience_key,
  experience_language,
  experience_name,
  item_id,
  item_number,
  pricing_attributes,
  pricing_price_amount,
  pricing_price_base_amount,
  pricing_price_base_currency,
  pricing_price_base_label,
  pricing_price_currency,
  pricing_price_includes_key,
  pricing_price_includes_label,
  pricing_price_label,
  status,
  _hash_code,
  _updated_at,
  _version
) values (
  '#{id}',
  '#{organization_id}',
  '#{experience_country}',
  '#{experience_currency}',
  '#{experience_id}',
  '#{experience_key}',
  '#{experience_language}',
  '#{experience_name}',
  '#{item_id}',
  '#{item_number}',
  '#{pricing_attributes}'::json,
  '#{pricing_price_amount}',
  '#{pricing_price_base_amount}',
  '#{pricing_price_base_currency}',
  '#{pricing_price_base_label}',
  '#{pricing_price_currency}',
  '#{pricing_price_includes_key}',
  '#{pricing_price_includes_label}',
  '#{pricing_price_label}',
  '#{status}',
  '#{_hash_code}',
  '#{_updated_at}',
  '#{_version}'
)
on conflict (id)
do nothing;
EOF
    # ==================================================
    # ==================================================
    # ==================================================
    sql = sql.split("\n").join(" ")
    puts sql

    open('mzwallace.sql', 'a') { |f|
      f.puts sql
    }

    puts "-- -----------------------------"
  end
  puts "-- ---------------------------------------------------------------------"
end

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
