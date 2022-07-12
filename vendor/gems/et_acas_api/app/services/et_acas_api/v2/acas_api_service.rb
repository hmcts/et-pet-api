require 'base64'
require 'httparty'
module EtAcasApi
  module V2
    class AcasApiService
      attr_reader :status, :errors

      def initialize(service_url: Rails.configuration.et_acas_api.json_service_url,
                     subscription_key: Rails.configuration.et_acas_api.json_subscription_key,
                     logger: Rails.logger)

        self.service_url = service_url
        self.subscription_key = subscription_key
        self.logger = logger
        self.errors = {}
      end

      # @param [Array<String>] ids The certificate ids to fetch
      # @param [Integer] user_id
      # @param [Array] into A collection to add the results to
      def call(ids, user_id:, into:)
        headers = {
          'Accept' => 'application/json',
          'Content-Type' => 'application/json',
          'Ocp-Apim-Subscription-Key' => subscription_key
        }
        body = {
          CertificateNumbers: ids
        }
        response = HTTParty.post(service_url, headers: headers, body: body.to_json)
        self.response_data = response
        set_status
        add_errors
        log_errors(ids: ids)
        build(collection: into)
      rescue Net::OpenTimeout => ex
        set_error_status_for(ex, ids: ids)
      ensure
        log_to_db(ids: ids, user_id: user_id)
      end

      # Indicates if this version support multi certificate requests
      def self.supports_multi?
        true
      end

      private

      def log_to_db(ids:, user_id:)
        case status
        when :found
          log_successes_to_db(user_id: user_id)
        when :not_found
          log_all_not_found_to_db(ids: ids, user_id: user_id)
        when :acas_server_error
          log_errors_to_db(ids: ids, user_id: user_id)
        end
      end

      def log_all_not_found_to_db(ids:, user_id:)
        ids.each do |id|
          DownloadLog.create! certificate_number: id,
                              description: 'Certificate Search Failure',
                              user_id: user_id,
                              message: 'Certificate Not Found'
        end
      end

      def log_errors_to_db(ids:, user_id:)
        ids.each do |id|
          DownloadLog.create! certificate_number: id,
                              description: 'Certificate Search Failure',
                              user_id: user_id,
                              message: 'Internal Server Error'
        end
      end

      def log_successes_to_db(user_id:)
        certificate_responses.each do |response|
          DownloadLog.create! certificate_number: response['CertificateNumber'],
                              message: 'CertificateFound',
                              description: 'Certificate Search Success',
                              method_of_issue: nil,
                              user_id: user_id
        end
      end

      def certificate_responses
        response_data.select { |r| r['CertificateDocument'] != 'not found' }
      end

      def set_error_status_for(ex, ids:)
        self.status = :acas_server_error
        errors[:base] ||= []
        errors[:base] << 'An error occured connecting to the ACAS service'
        logger.warn "An error occured connecting to the ACAS server when trying to find certificates '#{ids.join(',')}' - the error reported was '#{ex.message}'"
      end

      def set_status
        self.status = if !response_data.success?
                        :acas_server_error
                      elsif certificate_responses.empty?
                        :not_found
                      else
                        :found
                      end
      end

      def add_errors
        if status == :acas_server_error
          errors[:base] ||= []
          errors[:base] << 'An error occured in the ACAS service'
        end
      end

      def log_errors(ids:)
        if status == :acas_server_error
          logger.warn "An error occured in the ACAS server when trying to find certificates '#{ids.join(',')}' - the error reported was '#{response_data.dig('error', 'message')}'"
        end
      end

      def build(collection:)
        return unless status == :found

        response_data.each do |certificate_data|
          if certificate_data['CertificateDocument'] == 'not found'
            collection << EtAcasApi::CertificateNotFound.new(mapped_data(certificate_data))
          else
            collection << EtAcasApi::Certificate.new(mapped_data(certificate_data))
          end
        end

        collection
      end

      def mapped_data(certificate_data)
        {
          certificate_number: certificate_data['CertificateNumber'],
          certificate_base64: certificate_data['CertificateDocument']
        }
      end


      attr_accessor :service_url, :subscription_key, :response_data, :logger
      attr_writer :status, :errors
    end
  end
end
