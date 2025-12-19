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
require_relative "slack_outbox/base"
require_relative "slack_outbox/file_wrapper"
require_relative "slack_outbox/os"
require_relative "slack_outbox/mfp"
require_relative "slack_outbox/network_president"
require_relative "slack_outbox/health_insurance"

module SlackOutbox
  class Error < StandardError; end

  class << self
    def deliver(**) # rubocop:disable Naming/PredicateMethod
      implementor.call_async(**)
      true
    end

    def deliver!(**)
      implementor.call!(**).thread_ts
    end

    private

    def implementor = SlackOutbox::OS
  end
end

# Add deliver/deliver! methods to implementation classes for convenient API access
class SlackOutbox::Mfp
  class << self
    def deliver(**)
      call_async(**)
      true
    end

    def deliver!(**)
      call!(**).thread_ts
    end
  end
end

class SlackOutbox::NetworkPresident
  class << self
    def deliver(**)
      call_async(**)
      true
    end

    def deliver!(**)
      call!(**).thread_ts
    end
  end
end

class SlackOutbox::HealthInsurance
  class << self
    def deliver(**)
      call_async(**)
      true
    end

    def deliver!(**)
      call!(**).thread_ts
    end
  end
end
