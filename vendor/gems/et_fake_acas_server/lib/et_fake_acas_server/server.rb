require 'sinatra/base'
require 'et_fake_acas_server/forms/certificate_lookup_form'
require 'et_fake_acas_server/xml_builders/found_xml_builder'
require 'active_support/core_ext/numeric/time'
module EtFakeAcasServer
  class Server < Sinatra::Base
    get '/wsdl' do
      erb :wsdl
    end

    post '/Lookup/ECService.svc' do
      form = CertificateLookupForm.new(request.body.read, private_key_file: File.absolute_path(File.join('..', '..', 'temp_x509', 'acas', 'privatekey.pem'), __dir__))
      request.body.rewind
      form.validate
      case form.certificate_number
      when /\A(R|NE|MU)000200/ then
        erb :no_match
      when /\A(R|NE|MU)000201/ then
        erb :invalid_certificate_format
      when /\A(R|NE|MU)000500/ then
        erb :internal_error
      else
        xml_builder_for_found(form).to_xml
      end
    end

    private
    
    def xml_builder_for_found(form)
      data = OpenStruct.new claimant_name: 'Claimant Name',
                            respondent_name: 'Respondent Name',
                            date_of_issue: Time.parse('1 December 2017 12:00:00'),
                            date_of_receipt: Time.parse('1 January 2017 12:00:00'),
                            certificate_number: form.certificate_number,
                            message: 'Certificate found',
                            method_of_issue: 'Email',
                            certificate_file: File.absolute_path(File.join('..', 'pdfs', '76 EC (C) Certificate R000080.pdf'), __dir__)
      FoundXmlBuilder.new(form, rsa_et_certificate_path: File.absolute_path(File.join('..', '..', 'temp_x509', 'et', 'publickey.cer'), __dir__)).builder(data)
    end
  end
end

