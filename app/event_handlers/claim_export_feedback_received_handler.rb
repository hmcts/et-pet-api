class ClaimExportFeedbackReceivedHandler
  def handle(json)
    data = JSON.parse(json)
    export = Export.find(data['export_id'])
    export.events.create! uuid: SecureRandom.uuid, state: data['state'], percent_complete: data['percent_complete'], message: data['message'], data: { sidekiq: data['sidekiq'], external_data: data['external_data'] }
    export.update state: data['state'], percent_complete: data['percent_complete'], message: data['message'], external_data: export.external_data.merge(data['external_data']) unless export.state == 'complete'
  end
end
