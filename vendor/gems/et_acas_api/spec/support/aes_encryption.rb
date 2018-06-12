module EtAcasApi
  module Test
    class AesEncryption
      def iv
        'pretendiv'
      end

      def key
        'pretendkey'
      end

      def encrypt_from_acas(value)
        "Encrypted #{value}"
      end
    end
  end
end
