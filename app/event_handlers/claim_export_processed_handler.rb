# Called when an external exporter has an update for an export
# only complete messages are handled by this handler
class ClaimExportProcessedHandler
  def handle(json)
    data = JSON.parse(json)
    return unless data['state'] == 'complete'

    export = Export.find(data['export_id'])
    result = FetchAcasCertificatesService.call(export.resource)
    raise "There was a problem fetching acas certificates - will retry" unless result.success?

    Rails.application.event_service.publish('ExportClaimFilesAdded', export, result.new_files)
  end
end
