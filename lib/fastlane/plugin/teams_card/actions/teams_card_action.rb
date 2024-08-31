require 'fastlane/action'
require_relative '../helper/teams_card_helper'

module Fastlane
  module Actions
    class TeamsCardAction < Action
      def self.run(params)
        payload = {
          "type" => "message",
          "attachments" => [{
            "contentType" => "application/vnd.microsoft.card.adaptive",
            "contentUrl" => nil,
            "content" => {
              "type" => "AdaptiveCard",
              "body" => [
                {
                  "type" => "TextBlock",
                  "text" => params[:text],
                  "wrap" => true
                },
                {
                  "type" => "FactSet",
                  "facts" => params[:facts]
                }
              ],
              "$schema" => "http://adaptivecards.io/schemas/adaptive-card.json",
              "version" => "1.2"
            }
          }]
        }

        if params[:image] || params[:image_title]
          payload["attachments"][0]["content"]["body"].unshift(
            {
              "type" => "ColumnSet",
              "columns" => [
                {
                  "type" => "Column",
                  "items" => [
                    {
                      "type" => "Image",
                      "style" => "Person",
                      "url" => params[:image],
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
                      "text" => params[:image_title],
                      "wrap" => true
                    }
                  ],
                  "width" => "stretch",
                  "horizontalAlignment" => "Left",
                  "verticalContentAlignment" => "Center"
                }
              ]
            }
          )
        end

        if params[:title]
          payload["attachments"][0]["content"]["body"].unshift(
            {
              "type" => "TextBlock",
              "size" => "large",
              "weight" => "bolder",
              "text" => params[:title],
              "wrap" => true
            }
          )
        end

        if params[:open_url]
          payload["attachments"][0]["content"]["actions"] = [
            {
              "type" => "Action.OpenUrl",
              "title" => "Open",
              "url" => params[:open_url]
            }
          ]
        end

        send_message(params[:workflow_url], payload)
      end

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

      def self.is_message_success(response)
        if response.code.to_i == 202
          UI.message("🍾 The message was sent successfully")
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

      def self.example_code
        [
          'teams_card(
            workflow_url: "https://your.logic.azure.com:443/workflows/1234567890",
            title: "Notification Title",
            text: "A new release is ready for testing!",
            image: "https://raw.githubusercontent.com/fastlane/boarding/master/app/assets/images/fastlane.png",
            image_title: "Fastlane",
            open_url: "https://beta.itunes.apple.com/v1/app/_YOUR_APP_ID_",
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
          )'
        ]
      end

      def self.description
        "Easily send a message to a Microsoft Teams channel or group chat through the Power Automate Webhook connector"
      end

      def self.details
        "Send a message to a specific channel, group chat or chat on your Microsoft Teams organization via a Workflow of Power Automate"
      end

      def self.authors
        ["Kondamon"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
