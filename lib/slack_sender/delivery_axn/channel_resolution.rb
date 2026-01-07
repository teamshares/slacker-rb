# frozen_string_literal: true

module SlackSender
  class DeliveryAxn
    module ChannelResolution
      protected

      # TODO: just use memo once we update Axn
      def channel_to_use
        redirect_to_dev_channel? ? dev_channel : resolved_channel
      end

      def resolved_channel
        return channel unless validate_known_channel

        # TODO: once Axn supports preprocessing accessing other fields, we can remove this
        # and just reference channel directly.
        profile.channels[channel.to_sym]
      end

      # TODO: just use memo once we update Axn
      def text_to_use
        return text unless redirect_to_dev_channel?

        formatted_message = text&.lines&.map { |line| "> #{line}" }&.join

        [
          dev_channel_redirect_prefix,
          formatted_message,
        ].compact_blank.join("\n\n")
      end

      private

      def redirect_to_dev_channel? = dev_channel.present? && !SlackSender.config.in_production?

      def channel_display
        ch = resolved_channel
        is_channel_id?(ch) ? Slack::Messages::Formatting.channel_link(ch) : "`#{ch}`"
      end

      # TODO: this is directionally correct, but more-correct would involve conversations.list
      def is_channel_id?(given) # rubocop:disable Naming/PredicatePrefix
        given[0] != "#" && given.match?(/\A[CGD][A-Z0-9]+\z/)
      end

      def default_dev_channel_redirect_prefix = ":construction: _This message would have been sent to %s in production_"

      def dev_channel_redirect_prefix
        format(profile.dev_channel_redirect_prefix.presence || default_dev_channel_redirect_prefix, channel_display)
      end
    end
  end
end
