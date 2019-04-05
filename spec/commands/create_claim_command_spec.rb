require 'rails_helper'

RSpec.describe CreateClaimCommand do
  subject(:command) { described_class.new(**data.as_json.symbolize_keys) }

  let(:uuid) { SecureRandom.uuid }

  it 'applys the build claimant command before the build claim command'
end
