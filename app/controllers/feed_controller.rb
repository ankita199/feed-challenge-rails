require "rest_client"
class FeedController < ApplicationController
  def index
    begin
      activities_list = get_rest_call(ENV["API_ENDPOINT"]+"/activities")
      activities_list = JSON.parse(activities_list)
      shared,posted = [],[]
      final_result = []
      activities_list.map { |activity|
=begin    
        if(activity["verb"] === "posted")
          posted.push activity
        elsif(activity["verb"] === "shared")
          shared.push activity
        end
=end 
        final_result.push({"verb": activity['verb'],"actor": activity["actor"]})
      }
      render json: final_result
    rescue Exception => e
      render json: {}
    end
  end
  
  private
  
  def get_rest_call(url)
    begin
      RestClient.get(url) { |response, request, result, &block|
    case response.code
    when 200
      response
    else
      response.return!(&block)
    end
    }
    rescue RestClient::Unauthorized, RestClient::Forbidden => err
      puts 'Access denied'
      return err.response
    rescue RestClient::ImATeapot => err
      puts 'The server is a teapot! # RFC 2324'
      return err.response
    end
  end
end