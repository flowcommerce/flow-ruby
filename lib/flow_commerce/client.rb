module FlowCommerce
  DEFAULT_TOKEN_FILE_LOCATION = "~/.flow/token"

  # Creates a new instance of the flow client, using standard
  # conventions to identify the API TOKEN, checking in order:
  #
  #  1. an environment variable named FLOW_TOKEN
  #  2. an environment variable named FLOW_TOKEN_FILE containing
  #     the path of the file with the token in it
  #
  # @param base_url Alternate URL for the API
  def FlowCommerce.instance(opts = {})
    session_id = opts[:session_id].to_s.strip

    if session_id.length > 0
      auth = Io::Flow::V0::HttpClient::Authorization.session(session_id)
    else
      token = opts[:token].to_s.strip

      if token.empty?
        token = ENV['FLOW_TOKEN'].to_s.strip

        if token.empty?
          file = ENV['FLOW_TOKEN_FILE'].to_s.strip
          if file.empty?
            file = DEFAULT_TOKEN_FILE_LOCATION
          end
          path = File.expand_path(file)

          unless File.exists?(path)
            raise "File #{path} does not exist. You can specify environment variable FLOW_TOKEN or FLOW_TOKEN_FILE to explicitly provide the token"
          end

          token = IO.read(path).strip
          if token.empty?
            raise "File #{path} did not contain an API Token"
          end
        end
      end

      auth = Io::Flow::V0::HttpClient::Authorization.basic(token)
    end

    base_url = opts[:base_url].to_s.strip
    http_handler = opts[:http_handler]

    if base_url.empty?
      Io::Flow::V0::Client.at_base_url(authorization: auth, http_handler: http_handler)
    else
      Io::Flow::V0::Client.new(base_url, authorization: auth, http_handler: http_handler)
    end
  end
end
