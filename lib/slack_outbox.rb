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
require_relative "slack_outbox/profile"
require_relative "slack_outbox/profile_registry"
require_relative "slack_outbox/delivery_axn"
require_relative "slack_outbox/file_wrapper"

module SlackOutbox
  class Error < StandardError; end

  class << self
    def register_profile(name, config)
      ProfileRegistry.register(name, config)
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

    def deliver(**) # rubocop:disable Naming/PredicateMethod
      DeliveryAxn.call_async(profile: default_profile, **)
      true
    end

    def deliver!(**)
      DeliveryAxn.call!(profile: default_profile, **).thread_ts
    end
  end
end
