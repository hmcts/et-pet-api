class Event < ApplicationRecord
  belongs_to :attached_to, polymorphic: true
  enum name: {
    confirmation_email_sent: 'ConfirmationEmailSent',
    confirmation_email_failed: 'ConfirmationEmailFailed',
    claim_prepared: 'ClaimPrepared',
    claim_queued_for_export: 'ClaimQueuedForExport',
    claim_exported_to_atos_queue: 'ClaimExportedToAtosQueue',
    claim_acas_requested: 'ClaimAcasRequested',
    claim_manually_assigned: 'ClaimManuallyAssigned',
    response_exported_to_atos_queue: 'ResponseExportedToAtosQueue',
    response_repair_requested: 'ResponseRepairRequested',
    response_re_prepared: 'ResponseRePrepared',
    response_recreated_pdf: 'ResponseReCreatedPdf',
    response_deleted_broken_file: 'ResponseDeletedBrokenFile',
    response_repair_file_failed: 'ResponseRepairFileFailed'
  }
end
