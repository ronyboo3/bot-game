require 'pp'
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

    #食い止め(作業中のみ)
    #output_message(from, "ジュンビチューデース"+"\n\n"+params[:result][0][:content][:text])
    #return 

    user = User.by_mid(from).first rescue nil

    if !user
      User.create(from, "first_name", "a-1")
      message = "こんにちは！kosoっていいます！\nあなたのお名前は？"
      output_message(from, message)
      return
    end

    if params[:result][0][:content]["contentType"] == 1
      text = params[:result][0][:content][:text]
    elsif params[:result][0][:content]["contentType"] == 8
      #if user.level != "a-4"
        message = "スタンプはまだ対応してないんだ><"
        output_message(from, message)
        return
      #end
    else
      message = "対応してません><"
      output_message(from, message)
      return
    end

    #File.open("log/line_message.log","a") do |file|
    #  file.puts Time.now.to_s+" "+text+" : "+from+" ,"
    #end

    if "a-1" == user.level
      if 10 < text.length
        message = "名前が長いよ><\n短くしてくれる？"
      else
        message = text + " が名前でいい？\n\n1. はい\n2. いいえ"
        user.update(level: "a-2", name: text)
      end
      output_message(from, message)
      return
    end

    if "a-2" == user.level
      if text == "はい" || text == "1"
        user.update(level: "a-3")
        message = user.name + "よろしくね^^！\n早速話しかけてみよう！"
        output_message(from, message)
        return
      elsif text == "いいえ" || text == "2"
        user.update(level: "a-1")
        message = "うぇー(-o-)\n名前を教えてね！"
        output_message(from, message)
        return
      else
        message = "数字または「はい」か「いいえ」で答えてね><"
        output_message(from, message)
      end
    end

    if "a-3" == user.level
      partners = User.partners(user.mid) rescue nil
      if partners
        num = rand(partners.length)
        partner = partners[num]

        if !partner.partner && partner.partner != user.mid
          user.update(level: "a-4", partner: partner.mid)
          partner.update(level: "a-4", partner: user.mid)
          output_message(from, partner.name+"さんと繋がったよ！\n\n別の人とお話ししたいときは\n「ばいばい」\nって言ってね！")
          output_message(partner.mid, user.name+"さんと繋がったよ！\n\n別の人とお話ししたいときは\n「ばいばい」\nって言ってね！\n\n"+text)
        else
          message = "話し相手が見つからなかったよ><\nもう一度話しかけてみて？"
          output_message(from, message)
        end
      else
        message = "話し相手が見つからなかったよ><\nもう一度話しかけてみて？"
        output_message(from, message)
      end

    end

    if "a-4" == user.level
      if params[:result][0][:content]["contentType"] == 8
        output_sticker(user.partner, params[:result][0][:content]["contentMetadata"])
        #line_message("ua3c4c90fa2133580787a141316e73bcc", params[:result][0][:content]["contentMetadata"].to_s)
      else
        if "ばいばい" == text
          partner = User.by_mid(user.partner).first
          partner.update(level: "a-3", partner: nil)
          user.update(level: "a-3", partner: nil)
          output_message(from, "マッチングがリセットされたよ！\n他の人と話したいときはまた話しかけてみて！")
          output_message(partner.mid, "マッチングがリセットされたよ！\n他の人と話したいときはまた話しかけてみて！")
        else
          output_message(user.partner, user.name+": "+text)
        end
      end
    end

    end

    private

    def output_message(from, message)
      line_message(from, message)
      render json: [], status: :ok
    end

    def output_sticker(from, sticker)
      sticker_message(from, sticker)
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

    def sticker_message(to, sticker)
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
        contentType: 8,
        toType: 1,
        contentMetadata:{
        STKID: "47997",
        STKPKGID: "2000000",
        STKVER: "2"
      },
      }
      }
      ::RestClient.post 'https://trialbot-api.line.me/v1/events', request_params.to_json, request_headers
    end

end
