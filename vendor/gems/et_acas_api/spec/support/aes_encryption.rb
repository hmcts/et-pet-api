require 'securerandom'
module EtAcasApi
  module Test
    # AES-256-CBC
    class AesEncryption
      def key
        @key ||= '12345678901234567890123456789012'
      end

      def iv
        @iv ||= 'iv123456789012345678901234567890'
      end

      def encrypt_from_acas(value)
        encrypt_cipher = build_encrypt_cipher
        encrypt_cipher.encrypt(String.new(value, encoding: 'ascii-8bit'))
      end

      def decrypt_from_acas(value)
        decrypt_cipher = build_decrypt_cipher
        decrypt_cipher.decrypt(value).force_encoding('utf-8')
      end

      private

      def build_encrypt_cipher
        Mcrypt.new(:rijndael_256, :cbc, key, iv, :pkcs7)
      end

      def build_decrypt_cipher
        Mcrypt.new(:rijndael_256, :cbc, key, iv, :pkcs7)
      end
    end
  end
end
