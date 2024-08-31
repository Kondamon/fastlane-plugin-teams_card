require 'fastlane/action'
require 'fastlane_core'
require_relative '../helper/teams_card_helper'

module Fastlane
  module Actions
    class TeamsCardAction < Action
      def self.run(params)
        payload = build_payload(params)
        send_message(params[:workflow_url], payload)
      end

      # Build the payload for the Teams message
      def self.build_payload(params)
        # Use custom card if provided, otherwise build the card dynamically
        content = params[:custom_card] || {
          "type" => "AdaptiveCard",
          "body" => build_card_body(params),
          "$schema" => "http://adaptivecards.io/schemas/adaptive-card.json",
          "version" => "1.2"
        }

        payload = {
          "type" => "message",
          "attachments" => [{
            "contentType" => "application/vnd.microsoft.card.adaptive",
            "contentUrl" => nil,
            "content" => content
          }]
        }

        add_actions_to_payload(payload, params[:open_url]) if params[:open_url]
        payload
      end

      # Construct the body of the Adaptive Card
      def self.build_card_body(params)
        body = [
          build_text_block(params[:text]),
          build_fact_set(params[:facts])
        ]

        body.unshift(build_image_column_set(params[:image], params[:image_title])) if params[:image] || params[:image_title]
        body.unshift(build_title_block(params[:title])) if params[:title]
        body
      end

      # Create a text block for the card
      def self.build_text_block(text)
        {
          "type" => "TextBlock",
          "text" => text,
          "wrap" => true
        }
      end

      # Create a fact set for the card
      def self.build_fact_set(facts)
        {
          "type" => "FactSet",
          "facts" => facts
        }
      end

      # Create an image and title column set for the card
      def self.build_image_column_set(image, image_title)
        {
          "type" => "ColumnSet",
          "columns" => [
            {
              "type" => "Column",
              "items" => [
                {
                  "type" => "Image",
                  "style" => "Person",
                  "url" => image,
                  "size" => "Small"
                }
              ],
              "width" => "auto"
            },
            {
              "type" => "Column",
              "items" => [
                {
                  "type" => "TextBlock",
                  "weight" => "Bolder",
                  "text" => image_title,
                  "wrap" => true
                }
              ],
              "width" => "stretch",
              "horizontalAlignment" => "Left",
              "verticalContentAlignment" => "Center"
            }
          ]
        }
      end

      # Create a title block for the card
      def self.build_title_block(title)
        {
          "type" => "TextBlock",
          "size" => "large",
          "weight" => "bolder",
          "text" => title,
          "wrap" => true
        }
      end

      # Add actions to the payload if needed
      def self.add_actions_to_payload(payload, open_url)
        payload["attachments"][0]["content"]["actions"] ||= []
        payload["attachments"][0]["content"]["actions"] << {
          "type" => "Action.OpenUrl",
          "title" => "Open",
          "url" => open_url
        }
      end

      # Send the message to the Teams Webhook URL
      def self.send_message(url, payload)
        require 'net/http'
        require 'uri'
        json_headers = { 'Content-Type' => 'application/json' }
        uri = URI.parse(url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request = Net::HTTP::Post.new(uri.request_uri, json_headers)
        request.body = payload.to_json
        response = http.request(request)
        is_message_success(response)
      end

      # Check if the message was successfully posted
      def self.is_message_success(response)
        if response.code.to_i == 202
          UI.message("🔔 The card was posted successfully.")
          true
        else
          UI.user_error!("⚠️ An error occurred: #{response.body}")
        end
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :title,
                                       env_name: "TEAMS_MESSAGE_TITLE",
                                       optional: true,
                                       description: "The title that should be displayed on Teams"),

          FastlaneCore::ConfigItem.new(key: :image,
                                       env_name: "TEAMS_MESSAGE_IMAGE",
                                       sensitive: true,
                                       optional: true,
                                       description: "Displays an image on your activity (project logo, company logo, ...)"),

          FastlaneCore::ConfigItem.new(key: :image_title,
                                       env_name: "TEAMS_MESSAGE_IMAGE_TITLE",
                                       optional: true,
                                       description: "Displays a title next to your image"),

          FastlaneCore::ConfigItem.new(key: :text,
                                       env_name: "TEAMS_MESSAGE_TEXT",
                                       description: "The message you want to display",
                                       optional: false),

          FastlaneCore::ConfigItem.new(key: :facts,
                                       type: Array,
                                       env_name: "TEAMS_MESSAGE_FACTS",
                                       description: "Optional facts (assigned to, due date, status, branch, environment, ...)",
                                       default_value: []),

          FastlaneCore::ConfigItem.new(key: :open_url,
                                       env_name: "TEAMS_MESSAGE_OPEN_URL",
                                       description: "Optional url for a button at bottom of card",
                                       optional: true),

          FastlaneCore::ConfigItem.new(key: :custom_card,
                                       env_name: "TEAMS_MESSAGE_CUSTOM_CARD",
                                       description: "Custom Adaptive Card JSON object",
                                       optional: true,
                                       type: Hash),

          FastlaneCore::ConfigItem.new(key: :workflow_url,
                                       env_name: "TEAMS_MESSAGE_TEAMS_URL",
                                       sensitive: true,
                                       optional: false,
                                       description: "The URL of the incoming Webhook you created on your Microsoft Teams channel",
                                       verify_block: proc do |value|
                                         UI.user_error!("Invalid URL, must start with https://") unless value.start_with?("https://")
                                       end)
        ]
      end

      # Rest of the methods...
    end
  end
end
