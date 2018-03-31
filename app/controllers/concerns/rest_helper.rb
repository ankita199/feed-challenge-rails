module RestHelper
  @@urls = ActiveSupport::HashWithIndifferentAccess.new( 
    "list_activities": "activities",
    "list_shares": "shares",
    "list_posts": "posts"
  )
  def rest_get(url)
    begin
      RestClient.get(url) { |response|
        case response.code
        when 200
          JSON.parse(response)
        end
      }
    rescue RestClient::Unauthorized, RestClient::Forbidden => err
      puts 'Access denied'
      return []
    rescue Exception => e
      return []
    end
  end
  
  def get_url(method_name)
    ENV['API_ENDPOINT'] + @@urls[method_name]
  end
end