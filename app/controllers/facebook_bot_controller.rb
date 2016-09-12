class FacebookBotController < ApplicationController

  def callback

    token = "EAAY2aCj3h6YBAAbqLF06ZCnkEmFevdvxgCLWqCxVI5LowZBwOcBoeYb7ZCTkojhpTbHgBhfOhv856ZAZBo5m23NnJ5U8zeTxS8nnjzn8ZCAPXfggZBVkAA02mZAswZB4w3VcT46SRl51YiVTViIATt5zEoOvVZA5eaaXlnWjHZC2iiYBwZDZD"

    message = params["entry"][0]["messaging"][0]    

    if message.include?("message")

      #ユーザーの発言

      sender = message["sender"]["id"]
      text = message["message"]["text"]

      endpoint_uri = "https://graph.facebook.com/v2.6/me/messages?access_token=" + token
      request_content = {recipient: {id:sender},
                         message: {text: text}
      }

      content_json = request_content.to_json

      RestClient.post(endpoint_uri, content_json, {
        'Content-Type' => 'application/json; charset=UTF-8'
      }){ |response, request, result, &block|
        p response
        p request
        p result
      }
    else
      #botの発言
    end
  end

end
