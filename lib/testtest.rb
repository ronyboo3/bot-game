require 'rest-client'
class TestTest
def self.testtest(text, header)
  RestClient.post 'https://trialbot-api.line.me/v1/events', text, header
end
end
