# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HousekeepingService do
  describe '.call' do
    let(:delete_records_after) { 7.days }

    context 'with claims' do
      it 'must not schedule deletion jobs for claims that are not yet exported and received after cutoff date' do
        # Arrange
        claim = create(:claim, :ready_for_export_to_ccd, date_of_receipt: 1.day.ago)
        # Act
        described_class.call(delete_records_after: delete_records_after)
        # Assert
        expect(ClaimDestroyJob).not_to have_been_enqueued.with(claim.id)
      end

      it 'must not schedule deletion jobs for claims that are exported to ccd after cutoff date' do
        # Arrange
        claim = create(:claim, :exported_to_ccd, exported_to_ccd_on: 6.days.ago, date_of_receipt: 6.days.ago)
        # Act
        described_class.call(delete_records_after: delete_records_after)
        # Assert
        expect(ClaimDestroyJob).not_to have_been_enqueued.with(claim.id)
      end

      it 'must not schedule deletion jobs for claims that are exported to atos and received after cut off date' do
        # Arrange
        claim = create(:claim, :exported_to_atos, date_of_receipt: 1.day.ago)
        # Act
        described_class.call(delete_records_after: delete_records_after)
        # Assert
        expect(ClaimDestroyJob).not_to have_been_enqueued.with(claim.id)
      end

      it 'must not schedule deletion jobs for claims that have no export and received after cutoff date' do
        # Arrange
        claim = create(:claim, date_of_receipt: 1.day.ago)
        # Act
        described_class.call(delete_records_after: delete_records_after)
        # Assert
        expect(ClaimDestroyJob).not_to have_been_enqueued.with(claim.id)
      end

      it 'must schedule deletion jobs for claims that are not yet exported and received before cutoff date' do
        # Arrange
        claim = create(:claim, :ready_for_export_to_ccd, date_of_receipt: 8.days.ago)
        # Act
        described_class.call(delete_records_after: delete_records_after)
        # Assert
        expect(ClaimDestroyJob).to have_been_enqueued.with(claim.id)
      end

      it 'must schedule deletion jobs for claims that are exported to ccd before cutoff date' do
        # Arrange
        claim = create(:claim, :exported_to_ccd, exported_to_ccd_on: 8.days.ago, date_of_receipt: 9.days.ago)
        # Act
        described_class.call(delete_records_after: delete_records_after)
        # Assert
        expect(ClaimDestroyJob).to have_been_enqueued.with(claim.id)
      end

      it 'must schedule deletion jobs for claims that are exported to atos and received before cut off date' do
        # Arrange
        claim = create(:claim, :exported_to_atos, date_of_receipt: 8.days.ago)
        # Act
        described_class.call(delete_records_after: delete_records_after)
        # Assert
        expect(ClaimDestroyJob).to have_been_enqueued.with(claim.id)
      end

      it 'must schedule deletion jobs for claims that have no export and received before cutoff date' do
        # Arrange
        claim = create(:claim, date_of_receipt: 8.days.ago)
        # Act
        described_class.call(delete_records_after: delete_records_after)
        # Assert
        expect(ClaimDestroyJob).to have_been_enqueued.with(claim.id)
      end
    end

    context 'with responses' do
      it 'must not schedule deletion jobs for responses that are not yet exported and received after cutoff date' do
        # Arrange
        response = create(:response, :ready_for_export_to_ccd, date_of_receipt: 1.day.ago)
        # Act
        described_class.call(delete_records_after: delete_records_after)
        # Assert
        expect(ResponseDestroyJob).not_to have_been_enqueued.with(response.id)
      end

      it 'must not schedule deletion jobs for responses that are exported to ccd after cutoff date' do
        # Arrange
        response = create(:response, :exported_to_ccd, exported_to_ccd_on: 6.days.ago, date_of_receipt: 6.days.ago)
        # Act
        described_class.call(delete_records_after: delete_records_after)
        # Assert
        expect(ResponseDestroyJob).not_to have_been_enqueued.with(response.id)
      end

      it 'must not schedule deletion jobs for responses that are exported to atos and received after cut off date' do
        # Arrange
        response = create(:response, :exported_to_atos, date_of_receipt: 1.day.ago)
        # Act
        described_class.call(delete_records_after: delete_records_after)
        # Assert
        expect(ResponseDestroyJob).not_to have_been_enqueued.with(response.id)
      end

      it 'must not schedule deletion jobs for responses that have no export and received after cutoff date' do
        # Arrange
        response = create(:response, date_of_receipt: 1.day.ago)
        # Act
        described_class.call(delete_records_after: delete_records_after)
        # Assert
        expect(ResponseDestroyJob).not_to have_been_enqueued.with(response.id)
      end

      it 'must schedule deletion jobs for responses that are not yet exported and received before cutoff date' do
        # Arrange
        response = create(:response, :ready_for_export_to_ccd, date_of_receipt: 8.days.ago)
        # Act
        described_class.call(delete_records_after: delete_records_after)
        # Assert
        expect(ResponseDestroyJob).to have_been_enqueued.with(response.id)
      end

      it 'must schedule deletion jobs for responses that are exported to ccd before cutoff date' do
        # Arrange
        response = create(:response, :exported_to_ccd, exported_to_ccd_on: 8.days.ago, date_of_receipt: 9.days.ago)
        # Act
        described_class.call(delete_records_after: delete_records_after)
        # Assert
        expect(ResponseDestroyJob).to have_been_enqueued.with(response.id)
      end

      it 'must schedule deletion jobs for responses that are exported to atos and received before cut off date' do
        # Arrange
        response = create(:response, :exported_to_atos, date_of_receipt: 8.days.ago)
        # Act
        described_class.call(delete_records_after: delete_records_after)
        # Assert
        expect(ResponseDestroyJob).to have_been_enqueued.with(response.id)
      end

      it 'must schedule deletion jobs for responses that have no export and received before cutoff date' do
        # Arrange
        response = create(:response, date_of_receipt: 8.days.ago)
        # Act
        described_class.call(delete_records_after: delete_records_after)
        # Assert
        expect(ResponseDestroyJob).to have_been_enqueued.with(response.id)
      end
    end
  end
end
