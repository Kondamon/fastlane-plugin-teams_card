describe Fastlane::Actions::TeamsCardAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The teams_card plugin is working!")

      Fastlane::Actions::TeamsCardAction.run(nil)
    end
  end
end
