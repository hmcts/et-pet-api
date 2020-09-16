class ResponseExportedToAtosQueueHandler
  def handle(response, filename)
    response.events.response_exported_to_atos_queue.create(data: { filename: filename })
  end
end
