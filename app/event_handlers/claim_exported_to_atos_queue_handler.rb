class ClaimExportedToAtosQueueHandler
  def handle(claim, filename)
    claim.events.claim_exported_to_atos_queue.create(data: { filename: filename })
  end
end
