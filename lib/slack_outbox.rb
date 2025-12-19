# frozen_string_literal: true

require "active_support/core_ext/object/blank"
require "slack-ruby-client"
begin
  require "sidekiq"
rescue LoadError
  # Sidekiq is optional for runtime, only needed for async operations
end
require "axn"
require_relative "slack_outbox/version"
require_relative "slack_outbox/configuration"

module SlackOutbox
  class Error < StandardError; end
end

require_relative "slack_outbox/profile"
require_relative "slack_outbox/profile_registry"
require_relative "slack_outbox/delivery_axn"
require_relative "slack_outbox/file_wrapper"
require_relative "slack_outbox/multi_file_wrapper"

module SlackOutbox
  class << self
    def register(name = nil, **config)
      if name.nil? || name == :default
        # No positional arg or :default - register as :default and set it as default
        ProfileRegistry.default_profile = :default
        ProfileRegistry.register(:default, config)
      else
        # Other name - register named profile (existing behavior)
        ProfileRegistry.register(name, config)
      end
    end

    def profile(name)
      ProfileRegistry.find(name)
    end

    def default_profile
      ProfileRegistry.default_profile
    end

    def default_profile=(name)
      ProfileRegistry.default_profile = name
    end

    def deliver(**)
      raise Error, "No default profile set. Call SlackOutbox.register(...) first" if default_profile.nil?

      default_profile.deliver(**)
    end

    def deliver!(**)
      raise Error, "No default profile set. Call SlackOutbox.register(...) first" if default_profile.nil?

      default_profile.deliver!(**)
    end
  end
end
