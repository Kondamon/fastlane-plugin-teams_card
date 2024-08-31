require 'net/http'
require 'uri'
require 'json-schema'

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

    it 'uses the provided custom adaptive card' do
      # Define the custom card JSON
      custom_card = {
        "type" => "AdaptiveCard",
        "body" => [
          {
            "type" => "TextBlock",
            "text" => "Custom message content!",
            "wrap" => true
          }
        ],
        "$schema" => "http://adaptivecards.io/schemas/adaptive-card.json",
        "version" => "1.2"
      }

      # Parameters to test
      params = {
        workflow_url: "https://your.logic.azure.com:443/workflows/1234567890",
        custom_card: custom_card
      }

      # Execute the action
      result = Fastlane::Actions::TeamsCardAction.build_payload(params)

      # Assertions
      expect(result["attachments"][0]["content"]).to eq(custom_card)
    end
  end

  describe 'Schema Validation for Adaptive Card' do
    it 'validates the adaptive card against the schema' do
      params = {
        text: "A new release is ready for testing!",
        workflow_url: "https://your.logic.azure.com:443/workflows/1234567890",
        image_url: "https://raw.githubusercontent.com/fastlane/boarding/master/app/assets/images/fastlane.png",
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

      # Build the payload
      payload = Fastlane::Actions::TeamsCardAction.build_payload(params)

      # Define the Adaptive Card schema URL
      schema_url = "http://adaptivecards.io/schemas/adaptive-card.json"

      # Validate the payload against the schema
      expect do
        JSON::Validator.validate!(schema_url, payload['attachments'][0]['content'])
      end.not_to raise_error
    end
  end

  describe 'Mandatory Fields Validation' do
    it 'ensures mandatory fields are present' do
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

      # Build the payload
      payload = Fastlane::Actions::TeamsCardAction.build_payload(params)

      # Check for the presence of mandatory fields
      expect(payload['attachments'][0]['content']['body']).to include(
        hash_including("text" => params[:text])
      )

      # Check that the workflow_url is valid and not empty
      expect(params[:workflow_url]).not_to be_nil
      expect(params[:workflow_url]).to start_with("https://")
    end
  end
end
