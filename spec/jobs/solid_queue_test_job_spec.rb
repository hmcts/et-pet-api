require 'rails_helper'

RSpec.describe 'SolidQueueTestJob' do
  context 'when condition' do
    it 'succeeds' do
      job = SolidQueueTestJob.new
      job.perform
    end
  end
end
