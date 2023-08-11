require 'i18n'
require 'singleton'
require 'active_support/concern'
module EtApi
  module Test
    # @private
    class Backend < ::I18n::Backend::Simple
      def initialize(messaging_dir:)
        super()
        load_translations Dir.glob(File.join(messaging_dir, '**', '*.yml'))
        @initialized = true
      end
    end

    # A singleton class for translating i18n keys in the test suite.
    # This is to allow the test suite to have its own i18n yml files so that
    # all 'language' or 'messaging' that the test suite must use (like validating pdf's or email templates)
    # is expected to be the correct values.
    # Note that the API is generally not used for communication with the end user so this messaging stuff is
    # mainly used for general purpose lookup than true language stuff.
    # @TODO Maybe think of a better name for this
    class Messaging
      include Singleton
      # Translates using the specified locale
      # @param [Symbol] key The key to use to lookup the text from the language file(s)
      # @param [Symbol] locale - The locale to use
      # @param [Hash] options - Any options that the translation requires
      # @return [String] The translated text
      # @raise [::I18n::MissingTranslation] If the translation was not found
      def translate(key, locale:, **options)
        result = catch(:exception) do
          backend.translate(locale, key, options)
        end
        result.is_a?(::I18n::MissingTranslation) ? raise(result) : result
      end

      alias t translate

      # Localizes certain objects, such as dates and numbers to local formatting.
      def localize(object, locale: nil, format: nil, **options)
        raise I18n::Disabled, 'l' if locale == false

        format ||= :default
        backend.localize(locale, object, format, options)
      end

      alias l localize

      private

      def initialize(messaging_dir: File.absolute_path('../messaging', __FILE__))
        self.backend = Backend.new(messaging_dir: messaging_dir)
      end

      attr_accessor :backend
    end

    module I18n
      extend ActiveSupport::Concern

      private

      def t(*args, **kw_args)
        ::EtApi::Test::Messaging.instance.t(*args, **kw_args)
      end

      def l(*args, **kw_args)
        ::EtApi::Test::Messaging.instance.l(*args, **kw_args)
      end

      class_methods do
        def t(*args, **kw_args)
          ::EtApi::Test::Messaging.instance.t(*args, **kw_args)
        end

        def l(*args, **kw_args)
          ::EtApi::Test::Messaging.instance.l(*args, **kw_args)
        end

        def factory_translate(*args, **kw_args)
          ::EtApi::Test::Messaging.instance.factory_translate(*args, **kw_args)
        end
      end
    end
  end
end
