# frozen_string_literal: true

module Api
  module V1
    # Whilst the name 'Fee Group' is no longer really correct (as there are no fees),
    # this is called the fee group offices controller as that is what the endpoint suggests
    # It is for compatibility with the old JADU system and will be deprecated when we move to V2
    class FeeGroupOfficesController < ::ApplicationController
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
