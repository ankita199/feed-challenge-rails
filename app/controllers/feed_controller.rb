require "rest_client"
class FeedController < ApplicationController
  include RestHelper
  def index
    begin
      activities_list = rest_get(get_url("list_activities"))
      if(activities_list)
        ids_hash , obj_hash, final_result = {posted: [],shared: []} , {} , []
        activities_list.select{ |activity|
          id = get_id(activity)
          ids_hash[activity["verb"].to_sym].push(id)
        }
        obj_hash["shared"] = rest_get(get_url("list_shares")+"?ids=#{ids_hash[:shared].join(",")}")
        obj_hash["posted"] = rest_get(get_url("list_posts")+"?ids=#{ids_hash[:posted].join(",")}")
        activities_list.select{ |activity|
          tmp_hash = {verb: activity["verb"],actor: activity["actor"]}
          id = get_id(activity)
          obj_list = []
          obj = obj_hash[activity["verb"]].select{ |obj| obj["id"] == id }.try(:first)
          if(obj)
            obj["content"] ?  tmp_hash[:content] = obj["content"] : tmp_hash[:url] = obj["url"]
            tmp_hash[:description] = activity["actor"] + " " + activity["verb"] + " " + (obj["content"] || obj["url"])
          end
          final_result.push(tmp_hash)
        }
        render json: final_result
      end
    rescue Exception => e
      render json: {"error": e.message}
    end
  end
  
  private
  
  def get_id(obj)
    object_ary = obj["object"].split(":")
    return object_ary[1].to_i
  end
end