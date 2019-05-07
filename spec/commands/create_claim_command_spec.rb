require 'rails_helper'

RSpec.describe CreateClaimCommand do
  subject(:command) { described_class.new(**data) }

  let(:uuid) { SecureRandom.uuid }
  let(:data) { build(:json_build_claim_commands, :with_csv, :with_rtf, :with_pdf).as_json }
  let(:root_object) { build(:claim) }
  let(:example_meta_hash) { { example: :meta } }
  let(:mock_commands) { OpenStruct.new }
  let(:mock_command_classes) { OpenStruct.new }

  shared_context 'with mocked sub commands' do
    before do
      singular_commands = [:build_claim, :build_primary_respondent, :build_primary_claimant,
                  :build_primary_representative, :build_pdf_file, :build_claimants_file, :build_claim_details_file, :assign_reference_to_claim,
                  :assign_office_to_claim, :pre_allocate_pdf_file]
      singular_commands.each do |command|
        mock_command_classes[command] = Class.new(BaseCommand) do
          define_method :apply do | root_object, meta: {} |
            meta[:"dummy_key_for_#{command}"] = :"dummy_value_for_#{command}"
          end
        end
        allow(mock_command_classes[command]).to receive(:new).and_call_original
        command_class = "#{command.to_s.camelize}Command"
        stub_const(command_class, mock_command_classes[command])
      end

      collection_commands = [:build_secondary_claimants, :build_secondary_respondents]
      collection_commands.each do |command|
        mock_command_classes[command] = Class.new(BaseCommand) do
          define_method :initialize do | uuid:, data:, **args |
            super(uuid: uuid, data: { collection: data }, **args)
          end

          define_method :apply do | root_object, meta: {} |
            meta[:"dummy_key_for_#{command}"] = :"dummy_value_for_#{command}"
          end
        end
        allow(mock_command_classes[command]).to receive(:new).and_call_original
        command_class = "#{command.to_s.camelize}Command"
        stub_const(command_class, mock_command_classes[command])
      end
    end
  end

  include_context 'with disabled event handlers'
  include_context 'with mocked sub commands'
  describe '#apply' do
    it 'dispatches to BuildClaim' do
      # Act
      command.apply(root_object, meta: example_meta_hash)

      # Assert
      expect(example_meta_hash).to include "BuildClaim" => hash_including(dummy_key_for_build_claim: :dummy_value_for_build_claim)
    end

    it 'dispatches to BuildPrimaryRespondent' do
      # Act
      command.apply(root_object, meta: example_meta_hash)

      # Assert
      expect(example_meta_hash).to include "BuildPrimaryRespondent" => { dummy_key_for_build_primary_respondent: :dummy_value_for_build_primary_respondent }
    end

    it 'dispatches to BuildPrimaryClaimant' do
      # Act
      command.apply(root_object, meta: example_meta_hash)

      # Assert
      expect(example_meta_hash).to include "BuildPrimaryClaimant" => { dummy_key_for_build_primary_claimant: :dummy_value_for_build_primary_claimant }
    end

    it 'dispatches to BuildSecondaryClaimants' do
      # Act
      command.apply(root_object, meta: example_meta_hash)

      # Assert
      expect(example_meta_hash).to include "BuildSecondaryClaimants" => { dummy_key_for_build_secondary_claimants: :dummy_value_for_build_secondary_claimants}
    end

    it 'dispatches to BuildSecondaryRespondents' do
      # Act
      command.apply(root_object, meta: example_meta_hash)

      # Assert
      expect(example_meta_hash).to include "BuildSecondaryRespondents" => { dummy_key_for_build_secondary_respondents: :dummy_value_for_build_secondary_respondents}
    end

    it 'dispatches to BuildPrimaryRepresentative' do
      # Act
      command.apply(root_object, meta: example_meta_hash)

      # Assert
      expect(example_meta_hash).to include "BuildPrimaryRepresentative" => { dummy_key_for_build_primary_representative: :dummy_value_for_build_primary_representative }
    end

    it 'dispatches to BuildPdfFile' do
      # Act
      command.apply(root_object, meta: example_meta_hash)

      # Assert
      expect(example_meta_hash).to include "BuildPdfFile" => { dummy_key_for_build_pdf_file: :dummy_value_for_build_pdf_file }
    end

    it 'dispatches to BuildClaimantsFile' do
      # Act
      command.apply(root_object, meta: example_meta_hash)

      # Assert
      expect(example_meta_hash).to include "BuildClaimantsFile" => { dummy_key_for_build_claimants_file: :dummy_value_for_build_claimants_file }
    end

    it 'dispatches to BuildClaimDetailsFile' do
      # Act
      command.apply(root_object, meta: example_meta_hash)

      # Assert
      expect(example_meta_hash).to include "BuildClaimDetailsFile" => { dummy_key_for_build_claim_details_file: :dummy_value_for_build_claim_details_file }
    end

    it 'dispatches to AssignReferenceToClaim' do
      # Act
      command.apply(root_object, meta: example_meta_hash)

      # Assert
      expect(example_meta_hash).to include "BuildClaim" => hash_including(dummy_key_for_assign_reference_to_claim: :dummy_value_for_assign_reference_to_claim)
    end

    it 'dispatches to AssignOfficeToClaim' do
      # Act
      command.apply(root_object, meta: example_meta_hash)

      # Assert
      expect(example_meta_hash).to include "BuildClaim" => hash_including(dummy_key_for_assign_office_to_claim: :dummy_value_for_assign_office_to_claim)
    end

    it 'dispatches to PreAllocatePdfFile' do
      # Act
      command.apply(root_object, meta: example_meta_hash)

      # Assert
      expect(example_meta_hash).to include "BuildClaim" => hash_including(dummy_key_for_pre_allocate_pdf_file: :dummy_value_for_pre_allocate_pdf_file)
    end

    it 'creates the BuildClaim command with the correct data' do
      # Act
      command.apply(root_object, meta: example_meta_hash)

      # Assert
      input_data = data[:data].detect {|c| c[:command] == 'BuildClaim'}
      expect(mock_command_classes.build_claim).to have_received(:new).with(async: true, **input_data)
    end

    it 'creates the BuildPrimaryRespondent command with the correct data' do
      # Act
      command.apply(root_object, meta: example_meta_hash)

      # Assert
      input_data = data[:data].detect {|c| c[:command] == 'BuildPrimaryRespondent'}
      expect(mock_command_classes.build_primary_respondent).to have_received(:new).with(async: true, **input_data)
    end

    it 'creates the BuildPrimaryClaimant command with the correct data' do
      # Act
      command.apply(root_object, meta: example_meta_hash)

      # Assert
      input_data = data[:data].detect {|c| c[:command] == 'BuildPrimaryClaimant'}
      expect(mock_command_classes.build_primary_claimant).to have_received(:new).with(async: true, **input_data)
    end

    it 'creates the BuildSecondaryClaimants command with the correct data' do
      # Act
      command.apply(root_object, meta: example_meta_hash)

      # Assert
      input_data = data[:data].detect {|c| c[:command] == 'BuildSecondaryClaimants'}
      expect(mock_command_classes.build_secondary_claimants).to have_received(:new).with(async: true, **input_data)
    end

    it 'creates the BuildSecondaryRespondents command with the correct data' do
      # Act
      command.apply(root_object, meta: example_meta_hash)

      # Assert
      input_data = data[:data].detect {|c| c[:command] == 'BuildSecondaryRespondents'}
      expect(mock_command_classes.build_secondary_respondents).to have_received(:new).with(async: true, **input_data)
    end

    it 'creates the BuildPrimaryRepresentative command with the correct data' do
      # Act
      command.apply(root_object, meta: example_meta_hash)

      # Assert
      input_data = data[:data].detect {|c| c[:command] == 'BuildPrimaryRepresentative'}
      expect(mock_command_classes.build_primary_representative).to have_received(:new).with(async: true, **input_data)
    end

    it 'creates the BuildPdfFile command with the correct data' do
      # Act
      command.apply(root_object, meta: example_meta_hash)

      # Assert
      input_data = data[:data].detect {|c| c[:command] == 'BuildPdfFile'}
      expect(mock_command_classes.build_pdf_file).to have_received(:new).with(async: true, **input_data)
    end

    it 'creates the BuildClaimantsFile command with the correct data' do
      # Act
      command.apply(root_object, meta: example_meta_hash)

      # Assert
      input_data = data[:data].detect {|c| c[:command] == 'BuildClaimantsFile'}
      expect(mock_command_classes.build_claimants_file).to have_received(:new).with(async: true, **input_data)
    end

    it 'creates the BuildClaimDetailsFile command with the correct data' do
      # Act
      command.apply(root_object, meta: example_meta_hash)

      # Assert
      input_data = data[:data].detect {|c| c[:command] == 'BuildClaimDetailsFile'}
      expect(mock_command_classes.build_claim_details_file).to have_received(:new).with(async: true, **input_data)
    end

    it 'creates the AssignReferenceToClaim command with no data' do
      # Act
      command.apply(root_object, meta: example_meta_hash)

      # Assert
      expect(mock_command_classes.assign_reference_to_claim).to have_received(:new).with(async: true, uuid: instance_of(String), data: {}, command: 'AssignReferenceToClaim')
    end

    it 'creates the AssignOfficeToClaim command with no data' do
      # Act
      command.apply(root_object, meta: example_meta_hash)

      # Assert
      expect(mock_command_classes.assign_office_to_claim).to have_received(:new).with(async: true, uuid: instance_of(String), data: {}, command: 'AssignOfficeToClaim')
    end

    it 'creates the PreAllocatePdfFile command with no data' do
      # Act
      command.apply(root_object, meta: example_meta_hash)

      # Assert
      expect(mock_command_classes.pre_allocate_pdf_file).to have_received(:new).with(async: true, uuid: instance_of(String), data: {}, command: 'PreAllocatePdfFile')
    end
  end

  describe '#valid?' do
    context 'with all commands valid' do

      it 'contains the correct error key in the pdf_template_reference attributes' do
        # Act
        result = command.valid?

        # Assert
        expect(result).to be true
      end

    end

    context 'with an error in one of the commands' do
      before do
        mock_command_classes.build_primary_claimant.instance_eval do
          attribute :dummy_attribute, :string
          validates :dummy_attribute, presence: true
        end
      end

      it 'contains the correct error key in the pdf_template_reference attributes' do
        # Act
        result = command.valid?

        # Assert
        expect(result).to be false
      end

      it 'contains the correct error key in the pdf_template_reference attributes' do
        # Act
        command.valid?

        # Assert
        expect(command.errors[:'data[2].dummy_attribute']).to be_present
      end
    end
  end
end
