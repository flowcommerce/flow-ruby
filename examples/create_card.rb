module CreateCard

  def CreateCard.run(client, org)
    card = client.cards.post(org,
                             ::Io::Flow::V0::Models::CardForm.new(
                               :number => "4111 1111 1111 1111",
                               :name => "Joe Smith",
                               :expiration_month => 1,
                               :expiration_year => Time.now.year + 1,
                               :cvv => "737"
                             )
                            )

    puts "Card Created: token[%s]" % card.token
    card
  end

end
