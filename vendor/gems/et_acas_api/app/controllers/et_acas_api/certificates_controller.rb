module EtAcasApi
  class CertificatesController < ::EtAcasApi::ApplicationController
    def show
      certificate = ::EtAcasApi::Certificate.new
      result = QueryService.dispatch(query: 'Certificate', root_object: certificate, id: params[:id], user_id: request.headers['EtUserId'])
      case result.status
      when :found then
        render locals: { result: result, certificate: certificate }
      when :not_found then
        render :not_found, locals: { result: result }, status: :not_found
      when :invalid_certificate_format then
        render :invalid, locals: { result: result }, status: :unprocessable_entity
      when :acas_server_error
        render :invalid, locals: { result: result }, status: :internal_server_error
      when :invalid_user_id
        render :invalid, locals: { result: result }, status: :bad_request
      end
    end
  end
end
