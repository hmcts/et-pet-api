module EtAcasApi
  class CertificatesController < ::EtAcasApi::ApplicationController
    def show
      result = QueryService.dispatch(query: 'Certificate', root_object: ::EtAcasApi::Certificate.new, id: params[:id])
      case result.status
      when :found then
        render locals: { result: result }
      when :not_found then
        render :not_found, locals: { result: result }, status: :not_found
      when :invalid then
        render :invalid, locals: { result: result }, status: :unprocessable_entity
      end
    end
  end
end
