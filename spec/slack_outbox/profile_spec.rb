# frozen_string_literal: true

RSpec.describe SlackOutbox::Profile do
  let(:profile) do
    described_class.new(
      token: "SLACK_API_TOKEN",
      dev_channel: "C01H3KU3B9P",
      error_channel: "C03F1DMJ4PM",
      channels: { slack_development: "C01H3KU3B9P" },
      user_groups: { slack_development: "S123" }
    )
  end

  describe "#token" do
    it "returns the token value" do
      expect(profile.token).to eq("SLACK_API_TOKEN")
    end
  end

  describe "#dev_channel" do
    context "when dev_channel is provided" do
      it "returns the dev_channel value" do
        expect(profile.dev_channel).to eq("C01H3KU3B9P")
      end
    end

    context "when dev_channel is nil" do
      let(:profile) do
        described_class.new(
          token: "SLACK_API_TOKEN",
          dev_channel: nil,
          channels: {},
          user_groups: {}
        )
      end

      it "returns nil" do
        expect(profile.dev_channel).to be_nil
      end
    end
  end

  describe "#deliver" do
    it "calls DeliveryAxn.call_async with profile" do
      expect(SlackOutbox::DeliveryAxn).to receive(:call_async).with(profile: profile, channel: "C123", text: "test")
      profile.deliver(channel: "C123", text: "test")
    end

    it "returns true" do
      allow(SlackOutbox::DeliveryAxn).to receive(:call_async)
      expect(profile.deliver(channel: "C123", text: "test")).to be true
    end
  end

  describe "#deliver!" do
    let(:result) { instance_double("Result", thread_ts: "123.456") }

    it "calls DeliveryAxn.call! with profile" do
      expect(SlackOutbox::DeliveryAxn).to receive(:call!).with(profile: profile, channel: "C123", text: "test").and_return(result)
      expect(profile.deliver!(channel: "C123", text: "test")).to eq("123.456")
    end
  end
end

