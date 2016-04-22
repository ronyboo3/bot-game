class IndexController < ApplicationController

  protect_from_forgery with: :null_session

  CHANNEL_ID     = "1462258455"
  CHANNEL_SECRET = "74ea204c677bcdb16ff7a7b5aff8869b"
  CHANNEL_MID    = "u0c6e183ee6e2f32de111ce1068bbef47"

  def index
    http_request_body = request.raw_post
    hash = OpenSSL::HMAC::digest(OpenSSL::Digest::SHA256.new, CHANNEL_SECRET, http_request_body)
    signature = Base64.strict_encode64(hash)
    if signature != request.headers["X-LINE-CHANNELSIGNATURE"]
        render json: [], status: :ng
        return
    end

    from = params[:result][0][:content][:from]
    text = params[:result][0][:content][:text]

    line_message(from, text)

    render json: [], status: :ok
  end

  private

  def line_message(to, text)
    request_headers = {
          "Content-Type": "application/json",
          "X-Line-ChannelID": CHANNEL_ID,
          "X-Line-ChannelSecret": CHANNEL_SECRET,
          "X-Line-Trusted-User-With-ACL": CHANNEL_MID
      }
      request_params = {
          to: [to],
          toChannel: 1383378250, # Fixed value
          eventType: "138311608800106203", # Fixed value
          content:{
            contentType: 1,
            toType: 1,
            text: text
          }
      }
      ::RestClient.post 'https://trialbot-api.line.me/v1/events', request_params.to_json, request_headers
  end

end
