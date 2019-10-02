class ClaimExportSucceededHandler
  def handle(json)
    data = JSON.parse(json)
    export = Export.find(data['export_id'])
    export.events.create uuid: SecureRandom.uuid, state: 'complete', message: data['message'],percent_complete: 100, data: { sidekiq: data['sidekiq'], external_data: data['external_data'] }
    export.update state: 'complete', percent_complete: 100, message: data['message'], external_data: export.external_data.merge(data['external_data'])
  end
end
