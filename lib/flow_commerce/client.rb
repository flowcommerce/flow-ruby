module FlowCommerce

  DEFAULT_TOKEN_FILE_LOCATION = "~/.flow/token"

  # Creates a new instance of the flow cient, using standard
  # conventions to identify the API TOKEN, checking in order:
  #
  #  1. an environment variable named FLOW_TOKEN
  #  2. an environment variable named FLOW_TOKEN_FILE containing
  #     the path of the file with the token in it
  #
  # @param base_url Alternate URL for the API
  def FlowCommerce.instance(opts={})
    base_url = opts[:base_url].to_s.strip
    token = FlowCommerce.token(:token => opts[:token].to_s.strip) 

    auth = Io::Flow::V0::HttpClient::Authorization.basic(token)

    if base_url.empty?
      Io::Flow::V0::Client.at_base_url(:authorization => auth)
    else
      Io::Flow::V0::Client.new(base_url, :authorization => auth)
    end
  end

  def FlowCommerce.token(opts={})
    token = opts[:token].to_s.strip

    if token.empty?
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
    end
    token
  end

end
