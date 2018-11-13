class ClaimFromXmlCreatedHandler
  def handle(root, command:)
    import_service ||= ClaimXmlImportService.new(command.xml)
    export_service ||= ClaimExportService.new(root)
    import_service.uploaded_files = command.files
    import_service.import(into: root)
    export_service.to_be_exported
  end
end
