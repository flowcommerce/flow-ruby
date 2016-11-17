module CopyExperiences

  def CopyExperiences.run(client, org)
    target_org = Util::Ask.for_string("What is the org key to which to copy experiences? ")

    # base and target cannot be the same
    if org == target_org
      raise "Base organization[#{org}] and target organization[#{target_org}] cannot be the same"
    end

    target_token = Util::Ask.for_string("Please paste token for #{target_org}: ", :echo => false)
    target_client = FlowCommerce.instance(:token => target_token)

    # get all experiences from base org
    experiences = client.experiences.get(org, :limit => 100, :order => "position")
    max = experiences.size

    # iterate through experiences
    experiences.each_with_index do |exp, i|
      puts "[#{i+1}/#{max}] Experience key[#{exp.key}] from base org[#{org}] to target org[#{target_org}]"

      CopyExperiences.copy_experience(client, org, target_client, target_org, exp)
      CopyExperiences.copy_pricing(client, org, target_client, target_org, exp)
      CopyExperiences.copy_tiers(client, org, target_client, target_org, exp)

      puts ""
    end
  end

  def CopyExperiences.copy_experience(client, org, target_client, target_org, exp)
    puts "    - id: #{exp.id}"
    puts "    - key: #{exp.key}"
    puts "    - name: #{exp.name}"
    puts "    - delivered duty: #{exp.delivered_duty.value}"
    puts "    - country: #{exp.country}"
    puts "    - currency: #{exp.currency}"
    puts "    - language: #{exp.language}"
    puts "    - measurement system: #{exp.measurement_system.value}"
    puts "    - position: #{exp.position}"
    puts "    - region: #{exp.region.id}"

    # If experience already exists, we need to get the subcatalog_id
    # Or else we get generic error with message "subcatalog Id is required when updating an experience"
    # GET /:organization/experiences/:key
    begin
      subcatalog_id = target_client.experiences.get_by_key(target_org, exp.key).subcatalog.id
    rescue Exception => e
      subcatalog_id = nil
    end

    # PUT /:organization/experiences/:key
    new_experience = target_client.experiences.put_by_key(
      target_org,
      exp.key,
      ::Io::Flow::V0::Models::ExperienceForm.new(
        :key => exp.key,
        :name => exp.name,
        :region_id => exp.region.id,
        :delivered_duty => exp.delivered_duty,
        :country => exp.country,
        :currency => exp.currency,
        :language => exp.language,
        :measurement_system => exp.measurement_system,
        :position => exp.position,
        :subcatalog_id => subcatalog_id
      )
    )
    puts "    - UPSERTED EXPERIENCE: ID: #{new_experience.id}, KEY: #{new_experience.key}, NAME: #{new_experience.name}"
  end

  def CopyExperiences.copy_pricing(client, org, target_client, target_org, exp)
    pricing = client.experiences.get_pricing_by_key(org, exp.key)
    puts "    - vat: #{pricing.vat.value}"
    puts "    - duty: #{pricing.duty.value}"

    if rounding = pricing.rounding
      puts "    - rounding:"
      puts "       - type: #{rounding.type.value}"
      puts "       - rounding_method: #{rounding.method.value}"
      puts "       - rounding_value: #{rounding.value.to_f}"
    else
      puts "    - rounding: none"
    end

    # PUT /:organization/experiences/:key/pricing
    new_pricing = target_client.experiences.put_pricing_by_key(
      target_org,
      exp.key,
      ::Io::Flow::V0::Models::Pricing.new(
        :vat => pricing.vat,
        :duty => pricing.duty,
        :rounding => pricing.rounding
      )
    )
    puts "       - UPSERTED PRICING: VAT: #{new_pricing.vat.value}, DUTY: #{new_pricing.duty.value}, ROUNDING: #{new_pricing.rounding.to_json}"
  end

  def CopyExperiences.copy_tiers(client, org, target_client, target_org, exp)
    tiers = client.tiers.get(org, :experience => exp.key)
    max = tiers.size
    puts "    - tiers:"
    tiers.each_with_index do |tier, i|
      puts "      [#{i+1}/#{max}] Tier id[#{tier.name}] from base org[#{org}] to target org[#{target_org}]"
      puts "        - id: #{tier.id}"
      puts "        - name: #{tier.name}"
      puts "        - experience: #{tier.experience.id}"
      puts "        - currency: #{tier.experience.currency}"
      puts "        - integration: #{tier.integration.value}"
      puts "        - visibility: #{tier.visibility.value}"
      puts "        - strategy: #{tier.strategy.value}"
      puts "        - services: #{tier.services.map{|s| s.id}}"

      # tier rules
      rules = tier.rules
      puts "        - rules:"
      rules.each do |rule|
        puts "          - position: #{rule.position}"
        puts "            - query: #{rule.query}"
        puts "            - outcome: #{rule.outcome.to_hash.to_s}"
      end

      # POST /:organization/tiers
      new_tier = target_client.tiers.post(
        target_org,
        ::Io::Flow::V0::Models::TierForm.new(
          :name => tier.name,
          :experience => tier.experience.id,
          :currency => tier.experience.currency,
          :integration => tier.integration,
          :visibility => tier.visibility,
          :strategy => tier.strategy,
          :services => tier.services.map{|s| s.id},
          :rules => rules.map {|rule|
            ::Io::Flow::V0::Models::TierRuleForm.new(
              :position => rule.position,
              :query => rule.query,
              :outcome => rule.outcome
            )
          }
        )
      )
      puts "        - CREATED NEW TIER: ID: #{new_tier.id}, NAME: #{new_tier.name}, SERVICES: #{new_tier.services.map{|s| s.id}}"
    end
  end

end
