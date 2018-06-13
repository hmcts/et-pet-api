require 'securerandom'
module EtAcasApi
  module Test
    # AES-256-CBC
    class AesEncryption
      def key
        @key ||= 'testkey123456789012345678901234567890123456789012345678901234567890'
      end

      def iv
        @iv ||= 'testiv123456789012345678901234567890123456789012345678901234567890'
      end

      def encrypt_from_acas(value)
        encrypt_cipher = build_encrypt_cipher
        (encrypt_cipher.update(value) + encrypt_cipher.final).tap do |v|
          v
        end
      end

      def decrypt_from_acas(value)
        decrypt_cipher = build_decrypt_cipher
        decrypt_cipher.update(value) + decrypt_cipher.final
      end

      private

      def build_encrypt_cipher
        OpenSSL::Cipher::AES256.new(:CBC).tap do |c|
          c.encrypt
          c.iv = iv
          c.key = key
        end
      end

      def build_decrypt_cipher
        OpenSSL::Cipher::AES256.new(:CBC).tap do |c|
          c.decrypt
          c.iv = iv
          c.key = key
        end
      end

    end
  end
end
