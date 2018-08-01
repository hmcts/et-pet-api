class ClaimFromXmlCreatedHandler
  def handle(root, command:)
    import_service ||= ClaimXmlImportService.new(command.input_data[:xml])
    export_service ||= ClaimExportService.new(root)
    import_service.uploaded_files = command.input_data[:files]
    import_service.import(into: root)
    export_service.to_be_exported
  end
end
