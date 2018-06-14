module EtAcasApi
  class CertificatesController < ::EtAcasApi::ApplicationController
    def show
      certificate = ::EtAcasApi::Certificate.new
      result = QueryService.dispatch(query: 'Certificate', root_object: certificate, id: params[:id], user_id: request.headers['EtUserId'])
      case result.status
      when :found then
        render locals: { result: result, root_object: certificate }
      when :not_found then
        render :not_found, locals: { result: result }, status: :not_found
      when :invalid then
        render :invalid, locals: { result: result }, status: :unprocessable_entity
      end
    end
  end
end
