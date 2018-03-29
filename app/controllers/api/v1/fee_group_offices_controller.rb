module Api
  module V1
    class FeeGroupOfficesController < ::ActionController::API
      def create
        reference = ReferenceService.next_number
        office = OfficeService.lookup_postcode(my_params[:postcode])
        render locals: { reference: reference, office: office }, status: :created
      end

      private

      def my_params
        params.permit(:postcode)
      end
    end
  end
end