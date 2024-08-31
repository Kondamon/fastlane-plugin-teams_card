require 'net/http'
require 'uri'

describe Fastlane::Actions::TeamsCardAction do
  describe '#run' do
    it 'prints a message' do
      # Define the params hash with necessary keys and values
      params = {
        text: "A new release is ready for testing!",
        workflow_url: "https://your.logic.azure.com:443/workflows/1234567890",
        facts: [
          {
            "title" => "Environment",
            "value" => "Staging"
          },
          {
            "title" => "Release",
            "value" => "1.0.3"
          }
        ]
      }

      expect(Fastlane::UI).to receive(:message).with("🔔 The card was posted successfully.")

      # Mock the response object to return a 202 status code
      mock_response = instance_double("Net::HTTPResponse", code: '202')

      # Mock http call
      mock_http = instance_double("Net::HTTP")
      allow(Net::HTTP).to receive(:new).and_return(mock_http)
      allow(mock_http).to receive(:use_ssl=).with(true)
      allow(mock_http).to receive(:request).and_return(mock_response)

      allow(Net::HTTP).to receive(:start).and_return(mock_response)

      # Call the run method with the valid params
      Fastlane::Actions::TeamsCardAction.run(params)
    end
  end
end
