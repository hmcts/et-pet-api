require 'rails_helper'
require 'sidekiq_ar_middleware/client'
require 'sidekiq_ar_middleware'
require 'sidekiq/testing'
module SidekiqArMiddleware
  module Test
    class RenameUserWorker
      include Sidekiq::Worker

      def perform(user)
        user.update name: 'Renamed User'
      end
    end
  end

  RSpec.describe Client do
    context 'integration' do
      before do
        User.delete_all
      end

      around do |example|
        Sidekiq::Testing.fake! do
          example.run
        end
      end

      it 'passes the user to the worker' do
        user = User.create! name: 'Test User'
        Test::RenameUserWorker.perform_async(user)
        Test::RenameUserWorker.drain
        user.reload
        expect(user.name).to eql 'Renamed User'
      end
    end
  end
end
