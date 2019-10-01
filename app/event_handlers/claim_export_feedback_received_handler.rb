class ClaimExportFeedbackReceivedHandler
  def handle(json)
    data = JSON.parse(json)
    export = Export.find(data['export_id'])
    export.events.create! uuid: SecureRandom.uuid, state: data['state'], data: { sidekiq: data['sidekiq'], external_data: data['external_data'] }
    export.update state: data['state'], external_data: export.external_data.merge(data['external_data'])
  end
end
