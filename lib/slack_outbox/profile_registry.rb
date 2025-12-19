# frozen_string_literal: true

module SlackOutbox
  class ProfileNotFound < Error; end
  class DuplicateProfileError < Error; end

  class ProfileRegistry
    class << self
      def register(name, config)
        key = name.to_sym
        raise DuplicateProfileError, "Profile #{name} already registered" if all.key?(key)

        profile = Profile.new(**config)
        all[key] = profile
        profile
      end

      def find(name)
        raise ProfileNotFound, "Profile name cannot be nil" if name.nil?
        raise ProfileNotFound, "Profile name cannot be empty" if name.to_s.strip.empty?

        all[name.to_sym] or raise ProfileNotFound, "Profile '#{name}' not found"
      end

      def all
        @profiles ||= {}
      end

      def default_profile
        return find(@default_profile_name) if @default_profile_name

        @default_profile
      end

      def default_profile=(name)
        @default_profile_name = name.to_sym
      end

      def register_default(config)
        # For single-profile use cases - creates an anonymous default profile
        @default_profile ||= Profile.new(**config)
        @default_profile
      end

      def clear!
        @profiles = {}
        @default_profile_name = nil
        @default_profile = nil
      end
    end
  end
end
