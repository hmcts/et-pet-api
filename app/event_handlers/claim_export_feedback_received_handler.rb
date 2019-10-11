class ClaimExportFeedbackReceivedHandler
  def handle(json)
    data = JSON.parse(json)
    export = Export.find(data['export_id'])
    export.events.create! uuid: SecureRandom.uuid, state: data['state'], percent_complete: data['percent_complete'], message: data['message'], data: { sidekiq: data['sidekiq'], external_data: data['external_data'] }
    export.state = data['state'] unless data['state'].nil?
    export.percent_complete = data['percent_complete'] unless data['percent_complete'].nil?
    export.message = data['message'] unless data['message'].nil?
    export.external_data = export.external_data.merge(data['external_data'])
    export.save!
  end
end
