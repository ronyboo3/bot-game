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

    if params[:result][0][:content]["contentType"] == 1
      text = params[:result][0][:content][:text]
    elsif params[:result][0][:content]["contentType"] == 8
      message = "ふざけてんじゃねぇよ！"
      output_message(from, message)
      return
    else
      message = "わかんねぇよ！"
      output_message(from, message)
      return
    end

    File.open("log/line_message.log","a") do |file|
      file.puts text + ","
    end

    #食い止め(作業中のみ)
    output_message(from, "ジュンビチューデース")
    return

    user = User.by_mid(from).first rescue nil

    if !user
      User.create(from, "first_name", "a-1")
      message = "だれ？まず名前を教えて"
      output_message(from, message)
      return
    end

    if "a-1" == user.level
      if 10 < text.length
        message = "名前長すぎw\n短くして"
      elsif text.empty?
        message = "空欄はやめて"
      else
        message = text + " が名前でOK?\n\n1. はい\n2. いいえ"
        user.update(level: "a-2", name: text)
      end
      output_message(from, message)
      return
    end

    if "a-2" == user.level
      if text == "はい" || text == "1"
        user.update(level: "a-3")
        message = user.name + "よろしく！"
        output_message(from, message)
        return
      elsif text == "いいえ" || text == "2"
        user.update(level: "a-1")
        message = "あかんのかい！\n名前教えて！"
        output_message(from, message)
        return
      else
        message = "質問をしてるんだけど"
        output_message(from, message)
      end
    end

    if "a-3" == user.level
      output_message(from, "お楽しみに")
    end

  end

  private

  def output_message(from, message)
    line_message(from, message)
    render json: [], status: :ok
  end

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
