require 'rails_helper'

RSpec.describe ExportResponsesCommand do
  subject(:command) { described_class.new(event_service: mock_event_service, **data) }

  let(:mock_event_service) { class_spy(EventService) }
  let(:example_external_system_reference) { "ccd_manchester" }
  let(:example_responses) { create_list(:response, 3) }
  let(:example_external_system) { ExternalSystem.find_by!(reference: example_external_system_reference) }

  let(:uuid) { SecureRandom.uuid }
  let(:data) { build(:json_export_responses_command, external_system_id: example_external_system.id, response_ids: example_responses.map(&:id)).as_json }
  let(:root_object) { {} }

  include_context 'with disabled event handlers'

  describe '#apply' do
    it 'creates 3 separate events to create the export and schedule the communication' do
      # Act
      command.apply(root_object)

      # Assert
      aggregate_failures "Validating events raised" do
        expect(mock_event_service).to have_received(:publish).with('ResponseExported', external_system_id: example_external_system.id, response_id: example_responses[0].id)
        expect(mock_event_service).to have_received(:publish).with('ResponseExported', external_system_id: example_external_system.id, response_id: example_responses[1].id)
        expect(mock_event_service).to have_received(:publish).with('ResponseExported', external_system_id: example_external_system.id, response_id: example_responses[2].id)
      end
    end

  end

  describe '#valid?' do

    context 'with a response id that does not exist' do
      let(:data) { build(:json_export_responses_command, response_ids: example_responses.map(&:id) + [-1], external_system_id: example_external_system.id).as_json }

      it 'is false' do
        # Act
        result = command.valid?

        # Assert
        expect(result).to be false
      end

      it 'contains the correct error key in the response_ids attribute' do
        # Act
        command.valid?

        # Assert
        expect(command.errors.details[:response_ids]).to include(error: :response_not_found, response_id: -1, uuid: command.uuid, command: 'ExportResponses')
      end
    end

    context 'with all valid data' do
      let(:data) { build(:json_export_responses_command, response_ids: example_responses.map(&:id), external_system_id: example_external_system.id).as_json }

      it 'is true' do
        # Act
        result = command.valid?

        # Assert
        expect(result).to be true
      end
    end

    context 'with invalid external_system_id' do
      let(:data) { build(:json_export_responses_command, response_ids: example_responses.map(&:id), external_system_id: -1).as_json }

      it 'contains the correct error key in the external_system_id attributes' do
        # Act
        command.valid?

        # Assert
        expect(command.errors.details[:external_system_id]).to include(error: :external_system_not_found, external_system_id: -1, uuid: command.uuid, command: 'ExportResponses')
      end
    end
  end
end
