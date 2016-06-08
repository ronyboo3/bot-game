

def self.make_publish_data
  
  path = "/usr/local/var/bot-game/public/images/"
  confirm_url = ""
  sendding_url = ""

  Dir::glob( path + "/*.jpg" ).each do |fname|
    image_name = fname[-20,20]
    if image_name.include?("con")
      confirm_url = image_name
    else
      sendding_url = image_name
    end
  end

  account = Account.by_image_name(sendding_url).first rescue nil
  if account
    account.update(confirm_url: confirm_url, for_sendding_url: sendding_url)
  end

end
