module EtApi
  module Test
    module GovUkNotifyEmailObjects
      class Base
        def initialize(mail)
          self.mail = mail
        end

        private

        attr_accessor :mail
      end
    end
  end
end
