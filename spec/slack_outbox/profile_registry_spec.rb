# frozen_string_literal: true

RSpec.describe SlackOutbox::ProfileRegistry do
  after do
    described_class.clear!
  end

  describe ".register" do
    it "registers a profile with the given name" do
      profile = described_class.register(:test_profile,
        token: "TEST_TOKEN",
        dev_channel: "C123",
        channels: {},
        user_groups: {}
      )

      expect(profile).to be_a(SlackOutbox::Profile)
      expect(described_class.find(:test_profile)).to eq(profile)
    end

    it "allows dev_channel to be nil" do
      profile = described_class.register(:test_profile,
        token: "TEST_TOKEN",
        channels: {},
        user_groups: {}
      )

      expect(profile.dev_channel).to be_nil
    end

    it "raises error if profile already exists" do
      described_class.register(:test_profile,
        token: "TEST_TOKEN",
        dev_channel: "C123",
        channels: {},
        user_groups: {}
      )

      expect {
        described_class.register(:test_profile,
          token: "OTHER_TOKEN",
          dev_channel: "C456",
          channels: {},
          user_groups: {}
        )
      }.to raise_error(SlackOutbox::DuplicateProfileError, /already registered/)
    end
  end

  describe ".find" do
    before do
      described_class.register(:test_profile,
        token: "TEST_TOKEN",
        dev_channel: "C123",
        channels: {},
        user_groups: {}
      )
    end

    it "finds a registered profile" do
      profile = described_class.find(:test_profile)
      expect(profile).to be_a(SlackOutbox::Profile)
      expect(profile.dev_channel).to eq("C123")
    end

    it "raises error if profile not found" do
      expect {
        described_class.find(:nonexistent)
      }.to raise_error(SlackOutbox::ProfileNotFound, /not found/)
    end

    it "raises error if name is nil" do
      expect {
        described_class.find(nil)
      }.to raise_error(SlackOutbox::ProfileNotFound, /cannot be nil/)
    end

    it "raises error if name is empty" do
      expect {
        described_class.find("")
      }.to raise_error(SlackOutbox::ProfileNotFound, /cannot be empty/)
    end
  end

  describe ".default_profile" do
    context "when default_profile_name is set" do
      before do
        described_class.register(:test_profile,
          token: "TEST_TOKEN",
          dev_channel: "C123",
          channels: {},
          user_groups: {}
        )
        described_class.default_profile = :test_profile
      end

      it "returns the named profile" do
        expect(described_class.default_profile).to be_a(SlackOutbox::Profile)
        expect(described_class.default_profile.dev_channel).to eq("C123")
      end
    end

    context "when default_profile_name is not set but anonymous default exists" do
      before do
        described_class.register_default(
          token: "DEFAULT_TOKEN",
          dev_channel: "C999",
          channels: {},
          user_groups: {}
        )
      end

      it "returns the anonymous default profile" do
        expect(described_class.default_profile).to be_a(SlackOutbox::Profile)
        expect(described_class.default_profile.dev_channel).to eq("C999")
      end
    end

    context "when neither is set" do
      it "returns nil" do
        expect(described_class.default_profile).to be_nil
      end
    end
  end

  describe ".default_profile=" do
    it "sets the default profile name" do
      described_class.default_profile = :test_profile
      expect(described_class.instance_variable_get(:@default_profile_name)).to eq(:test_profile)
    end
  end

  describe ".register_default" do
    it "creates an anonymous default profile" do
      profile = described_class.register_default(
        token: "DEFAULT_TOKEN",
        dev_channel: "C999",
        channels: {},
        user_groups: {}
      )

      expect(profile).to be_a(SlackOutbox::Profile)
      expect(described_class.default_profile).to eq(profile)
    end

    it "returns the same profile on subsequent calls" do
      profile1 = described_class.register_default(
        token: "DEFAULT_TOKEN",
        dev_channel: "C999",
        channels: {},
        user_groups: {}
      )

      profile2 = described_class.register_default(
        token: "OTHER_TOKEN",
        dev_channel: "C888",
        channels: {},
        user_groups: {}
      )

      expect(profile1).to eq(profile2)
    end
  end

  describe ".clear!" do
    before do
      described_class.register(:test_profile,
        token: "TEST_TOKEN",
        dev_channel: "C123",
        channels: {},
        user_groups: {}
      )
      described_class.default_profile = :test_profile
      described_class.register_default(
        token: "DEFAULT_TOKEN",
        dev_channel: "C999",
        channels: {},
        user_groups: {}
      )
    end

    it "clears all registered profiles" do
      described_class.clear!
      expect(described_class.all).to be_empty
      expect(described_class.default_profile).to be_nil
    end
  end
end

