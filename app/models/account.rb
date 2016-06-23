class Account < ActiveRecord::Base

  VALID_IMAGE_REGEX = /[0-9]{4}-[0-9]{4}-[0-9]{2}-[0-9]{3}.jpg/
  validates :image_name, presence: true, uniqueness: true, format: { with: VALID_IMAGE_REGEX }
  validates :customer_name, presence: true

  scope :by_image_name, ->(name) { where(image_name: name) }
  scope :publishing, -> { where(confirm_url: nil) }
  scope :published, -> { where.not(confirm_url: nil) }


  def self.create_account(image_name, customer_name)
    account = self.new
    account.attributes = {image_name: image_name, customer_name: customer_name}
    account.save!
  rescue ActiveRecord::RecordInvalid => e
  end

  def self.make_publish_data(sold_image_name)

    path = "/usr/local/var/bot-game/public/images/"
    confirm_url = ""
    sendding_url = ""
    sold_image = sold_image_name[0, 12]

    Dir::glob( path + "/#{sold_image}*" ).each do |fname|
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

end
