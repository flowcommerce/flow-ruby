module Util

  class MenuItem

    attr_reader :title, :path, :procedure

    def initialize(title, path, procedure)
      @title = title
      @path = path
      @procedure = procedure
    end

    def run(client, org)
      load @path
      @procedure.call(client, org)
    end
    
  end

  MENU = [
    Util::MenuItem.new("Catalog: Create items", "examples/create_items.rb", Proc.new { |client, org| CreateItems.run(client, org) }),
    Util::MenuItem.new("Catalog: Show items", "examples/show_items.rb", Proc.new { |client, org| ShowItems.run(client, org) }),
    
    Util::MenuItem.new("Catalog: Show statistics", "examples/catalog_statistics.rb", Proc.new { |client, org| CatalogStatistics.run(client, org) }),
    Util::MenuItem.new("Catalog: Delete all items", "examples/delete_all_items.rb", Proc.new { |client, org| DeleteAllItems.run(client, org) }),

    Util::MenuItem.new("Experiences: Show all", "examples/show_experiences.rb", Proc.new { |client, org| ShowExperiences.run(client, org) }),
    Util::MenuItem.new("Experiences: Create", "examples/create_experience.rb", Proc.new { |client, org| CreateExperience.run(client, org) }),
    Util::MenuItem.new("Experiences: Delete All", "examples/delete_all_experiences.rb", Proc.new { |client, org| DeleteAllExperiences.run(client, org) }),
    Util::MenuItem.new("Experience: Copy to another org", "examples/copy_experiences.rb", Proc.new { |client, org| CopyExperiences.run(client, org) }),
    Util::MenuItem.new("Experience Items: Show", "examples/show_experience_items.rb", Proc.new { |client, org| ShowExperienceItems.run(client, org) }),

    Util::MenuItem.new("Order: Create", "examples/example_order.rb", Proc.new { |client, org| ExampleOrder.run(client, org) }),

    Util::MenuItem.new("Landed Cost", "examples/landed_cost.rb", Proc.new { |client, org| LandedCost.run(client, org) }),

    Util::MenuItem.new("Payment: Create card", "examples/create_card.rb", Proc.new { |client, org| CreateCard.run(client, org) }),
    Util::MenuItem.new("Payment: Create authorization", "examples/create_authorization.rb", Proc.new { |client, org| CreateAuthorization.run(client, org) })
  ]

  def Util.display_menu
    puts ""
    puts "Available examples:"
    MENU.each_with_index do |item, i|
      puts "  %s: %s" % [i + 1, item.title]
    end
    puts ""
  end

  def Util.pick_n(items, n)
    items.shuffle.first(n)
  end

  def Util.pct(value)
    if value.nil? || value == 0
      "0%"
    else
      value = sprintf('%.2f', value.to_f.round(2))
      value.sub(/\.00$/, '') + "%"
    end
  end
  
  # Simple library to ask user for input, with easy mocakability for
  # testing
  class Ask

    TRUE_STRINGS = ['y', 'yes'] unless defined?(TRUE_STRINGS)

    # Asks the user a question. Expects a string back.
    #
    # @param default: A default value
    # @param echo: If true (the default), we echo what the user types
    #        to the screen. If false, we do NOT echo.
    def Ask.for_string(message, opts={})
      default = opts.delete(:default)
      echo = opts[:echo].nil? ? true : opts.delete(:echo)

      final_message = message.dup
      if default
        final_message << " [%s] " % default
      end

      value = nil
      while value.to_s == ""
        print final_message
        value = get_input(echo).strip
        if value.to_s == "" && default
          value = default.to_s.strip
        end
      end
      value
    end

    # Asks the user a question. Returns a positive integer.
    def Ask.for_positive_integer(message)
      value = Ask.for_string("%s " % message)
      if value.to_i.to_s == value && value.to_i > 0
        value.to_i
      else
        puts "Please enter an integer > 0"
        Ask.for_positive_integer(message)
      end
    end

    # Asks the user a question. Returns a boolean. Boolean is defined as
    # matching the strings 'y' or 'yes', case insensitive
    def Ask.for_boolean(message)
      value = Ask.for_string("%s (y/n) " % message)
      TRUE_STRINGS.include?(value.downcase)
    end

    def Ask.for_password(message)
      Ask.for_string(message, :echo => false)
    end

    # here to help with tests
    def Ask.get_input(echo)
      if echo
        STDIN.gets
      else
        settings = `stty -g`.strip
        begin
          `stty -echo`
          input = STDIN.gets
          puts ""
        ensure
          `stty #{settings}`
        end
        input
      end
    end

  end

end
