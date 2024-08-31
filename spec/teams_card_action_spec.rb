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
      
      allow(Fastlane::Actions::TeamsCardAction).to receive(:send_message).and_return(true)

      # Expect the Fastlane UI to receive a message
      expect(Fastlane::UI).to receive(:message).with("🔔 The card was posted successfully.")

      # Call the run method with the valid params
      Fastlane::Actions::TeamsCardAction.run(params)
    end
  end
end
