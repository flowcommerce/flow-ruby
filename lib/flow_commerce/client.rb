module FlowCommerce

  DEFAULT_TOKEN_FILE_LOCATION = "~/.flow/token"

  # Creates a new instance of the flow cient, using standard
  # conventions to identify the API TOKEN, checking in order:
  #
  #  1. an environment variable named FLOW_TOKEN
  #  2. an environment variable named FLOW_TOKEN_FILE containing
  #     the path of the file with the token in it
  #
  # @param module e.g. catalog, experience - this is temporary
  #        until Flow consolidates its APIs into a single domain
  def FlowCommerce.instance(app)
    token = ENV['FLOW_TOKEN'].to_s.strip

    if token.empty?
      file = ENV['FLOW_TOKEN_FILE'].to_s.strip
      if file.empty?
        file = DEFAULT_TOKEN_FILE_LOCATION
      end
      path = File.expand_path(file)

      if !File.exists?(path)
        raise "File %s does not exist. You can specify environment variable FLOW_TOKEN or FLOW_TOKEN_FILE to explicitly provide the token" % path
      end

      token = IO.read(path).strip
      if token.empty?
        raise "File %s did not contain an API Token" % path
      end
    end

    case app
    when "catalog"
      FlowCommerce.catalog_client(token, opts = {})
    when "experience"
      FlowCommerce.experience_client(token, opts = {})
    when "harmonization"
      FlowCommerce.harmonization_client(token, opts = {})
    else
      raise "Invalid module name[%s]" % app
    end
  end
  
  def FlowCommerce.catalog_client(token, opts = {})
    if token.empty?
      raise "ERROR: Token is required"
    end

    base_url = opts[:base_url].to_s.strip
    auth = Io::Flow::Catalog::V0::HttpClient::Authorization.basic(token)

    if base_url.empty?
      Io::Flow::Catalog::V0::Client.at_base_url(:authorization => auth)
    else
      Io::Flow::Catalog::V0::Client.new(base_url, :authorization => auth)
    end
  end

  def FlowCommerce.experience_client(token, opts = {})
    if token.empty?
      raise "ERROR: Token is required"
    end

    base_url = opts[:base_url].to_s.strip
    auth = Io::Flow::Experience::V0::HttpClient::Authorization.basic(token)

    if base_url.empty?
      Io::Flow::Experience::V0::Client.at_base_url(:authorization => auth)
    else
      Io::Flow::Experience::V0::Client.new(base_url, :authorization => auth)
    end
  end

  def FlowCommerce.harmonization_client(token, opts = {})
    if token.empty?
      raise "ERROR: Token is required"
    end

    base_url = opts[:base_url].to_s.strip
    auth = Io::Flow::Harmonization::V0::HttpClient::Authorization.basic(token)

    if base_url.empty?
      Io::Flow::Harmonization::V0::Client.at_base_url(:authorization => auth)
    else
      Io::Flow::Harmonization::V0::Client.new(base_url, :authorization => auth)
    end
  end

end
