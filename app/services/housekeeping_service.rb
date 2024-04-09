# frozen_string_literal: true

class HousekeepingService
  def self.call(delete_records_after: Rails.application.config.delete_records_after)
    new(delete_records_after: delete_records_after).call
  end

  def initialize(delete_records_after:)
    @delete_records_after = delete_records_after
  end

  attr_reader :delete_records_after

  def call
    delete_old_claims
    delete_old_responses
  end

  private

  def delete_old_claims
    date_time = delete_records_after.ago
    claims_to_delete = Set.new
    Claim.exported_to_ccd_before(date_time).all.each do |claim|
      claims_to_delete.add(claim.id)
    end
    Claim.unexported_to_ccd.submitted_before(date_time).all.each do |claim|
      claims_to_delete.add(claim.id)
    end
    Claim.exported_or_not_exported_to_atos.submitted_before(date_time).all.each do |claim|
      claims_to_delete.add(claim.id)
    end

    claims_to_delete.each do |claim_id|
      ClaimDestroyJob.set(wait: 1.hour).perform_later(claim_id)
    end
  end

  def delete_old_responses
    date_time = delete_records_after.ago
    responses_to_delete = Set.new
    Response.exported_to_ccd_before(date_time).all.each do |response|
      responses_to_delete.add(response.id)
    end
    Response.unexported_to_ccd.submitted_before(date_time).all.each do |response|
      responses_to_delete.add(response.id)
    end
    Response.exported_or_not_exported_to_atos.submitted_before(date_time).all.each do |response|
      responses_to_delete.add(response.id)
    end

    responses_to_delete.each do |claim_id|
      ResponseDestroyJob.set(wait: 1.hour).perform_later(claim_id)
    end
  end
end
