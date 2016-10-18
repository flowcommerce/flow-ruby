require 'json'
require 'pathname'
require 'SecureRandom'

module ExampleOrder

  DIR = Pathname.new(File.join(File.dirname(__FILE__), "..")).cleanpath

  def ExampleOrder.json_file(path)
    JSON.parse(read_file(path))
  end
  
  def ExampleOrder.read_file(path)
    full = File.join(DIR, path)
    if !File.exists?(full)
      puts "ERROR: Cannot find file %s" % full
      exit(1)
    end
    IO.read(full).strip
  end

  def ExampleOrder.create_card(client, org)
    card_info = json_file("card-info.#{org}.json")
    form = ::Io::Flow::V0::Models::CardForm.new(card_info)
    client.cards.post(org, form)
  end

  def ExampleOrder.create_order(client, org)
    item_number = org == "demo" ? "sku-2" : "sku-201610-9679"
    discount = org == "demo" ? 20 : 12
    number = SecureRandom.uuid.to_s.gsub(/\-/, '')

    form = ::Io::Flow::V0::Models::OrderPutForm.new(
      :items => [
        { :number => item_number, :quantity => 1, :center => "flow", :price => { :amount => 1.5, :currency => "CAD" } },
      ],
      :customer => {
        :name => { :first => "Michael", :last => "Bryzek" },
        :phone => "+1-646-813-9414",
        :email => "somebody@test.flow.io"
      },
      :destination => {
        :streets => [ "512 Danforth Ave" ],
        :city => "Toronto",
        :province => "Ontario",
        :postal => "M4K 1P6",
        :country => "CAN"
      },
      :discount => { :amount => discount, :currency => "CAD" }      
    )

    client.orders.put_by_number(org, number, form, :country => "CAN")
  end
  
  def ExampleOrder.run(client, org)
    do_card = false
    do_order = false
    do_auth = false
    do_capture = true

    if do_card
      card = ExampleOrder.create_card(client, org)
      puts "Created card %s ending in %s" % [card.id, card.last4]
      card_token = card.token
    else
      card_token = "F96l6mkBn8UTiBYAbbYfqE1jU63ABSIpLV3wQW51qN6vppMJ5M3cDqgi5vev26UM"
    end

    if do_order
      order = ExampleOrder.create_order(client, org)
      puts "Created order %s for total of %s" % [order.number, order.total.label]
      order_number = order.number
    else
      order_number = "3543ed706ad14c1cb032742413d98d3c"
    end

    if do_auth
      auth = client.authorizations.post(org,
                                        ::Io::Flow::V0::Models::MerchantOfRecordAuthorizationForm.new(
                                         :token => card_token,
                                         :order_number => order.number
                                        )
                                       )
      auth_key = auth.key
      auth_amount = auth.amount.to_f
      auth_currency = auth.currency
      auth_status = auth.result.status.value
      puts "Authorization %s for %s %s created. status: %s" % [auth_key, auth_amount, auth_currency, auth_status]
    else
      auth_key = "aut-035920fa0e8f44c2abc2ea71ba58ae82"
      auth_amount = 3.11
      auth_currency = "CAD"
      auth_status = "authorized"
    end

    if do_capture
      capture = client.captures.post(org,
                                     ::Io::Flow::V0::Models::CaptureForm.new(
                                       :authorization_id => auth_key,
                                       :amount => auth_amount,
                                       :currency => auth_currency
                                     )
                                    )
      capture_id = capture.id
      puts "Capture created: " + capture.inspect
    else
      raise "TODO"
    end
  end

end
