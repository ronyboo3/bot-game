require 'pp'
class PadRmtController < ApplicationController

  def index
    account = Account.by_image_name(params[:url]).first rescue nil
    if account
      if account.confirm_url
        @status = 1
        @img_confirm = account.confirm_url
        @img_for_sendding = account.for_sendding_url
      else
        @status = 0
        Account.make_publish_data(account.image_name)
      end
    end
    @error = params[:error]
  end

  def publish
    pp `echo '' > script/pad/image_name.lua`
    pp `echo 'IMAGE_NAME="#{params[:url]}"' > script/pad/image_name.lua`
    account = nil
    if !Account.exists?(:image_name => params[:url])
      account = Account.create_account(params[:url], params[:customer])
    end
    redirect_to :action => "index", :url => params[:url]
  end

end
