# frozen_string_literal: true

module SlackOutbox
  class Profile
    attr_reader :token, :dev_channel, :error_channel, :channels, :user_groups

    def initialize(token:, dev_channel: nil, error_channel: nil, channels: {}, user_groups: {})
      @token = token
      @dev_channel = dev_channel
      @error_channel = error_channel
      @channels = channels.freeze
      @user_groups = user_groups.freeze
    end

    def deliver(**kwargs)
      DeliveryAxn.call_async(profile: self, **kwargs)
      true
    end

    def deliver!(**kwargs)
      DeliveryAxn.call!(profile: self, **kwargs).thread_ts
    end
  end
end

