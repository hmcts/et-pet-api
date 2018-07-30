# frozen_string_literal: true

module Api
  module V1
    # Whilst the name 'Fee Group' is no longer really correct (as there are no fees),
    # this is called the fee group offices controller as that is what the endpoint suggests
    # It is for compatibility with the old JADU system and will be deprecated when we move to V2
    class FeeGroupOfficesController < ::ApplicationController
      def create
        root_object = {}
        result = CommandService.dispatch root_object: root_object, data: {}, **command_data
        EventService.publish('ReferenceCreated', root_object, command: result)
        render locals: { result: result, data: root_object },
               status: (result.valid? ? :created : :unprocessable_entity)
      end

      private

      def my_params
        params.permit(:postcode)
      end

      def command_data
        {
          command: 'CreateReference',
          uuid: SecureRandom.uuid,
          data: {
            'post_code' => my_params['postcode']
          }
        }
      end
    end
  end
end
